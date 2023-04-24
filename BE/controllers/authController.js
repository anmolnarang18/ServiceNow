const User = require("../models/authModel");
const Service = require("../models/serviceModel");
const Orders = require("../models/orderModel");
const favService = require("../models/favModel");

const { generateToken } = require("../utils/generateToken");
const { EMAIL_VALIDATION, USER_TYPE } = require("../shared/Constants");
const sendError = require("../utils/sendError");

exports.login = async (req, res, next) => {
 
  const { email, password, type } = req.body;
  console.log(email,password,type)
  if (!email || !password || !type) {
    return next(sendError(422, "Please enter all required fields."));
  }

  if (!EMAIL_VALIDATION.test(email)) {
    return next(sendError(422, "Please enter valid email address."));
  }

  if (password.length < 6) {
    return next(sendError(422, "Password must be atleast 6 characters long."));
  }

  try {
    const user = await User.findOne({ email });
    if (user) {
      if (user.type != type) return res.status(404).json("User not found!");
    
      const isCorrect = await user.matchPassword(password);
      if (!isCorrect) {
        return next(sendError(422, "Invalid email or password"));
      }

      const token = generateToken(user.email, user.password);

      return res.status(200).json({
        message: "User logged in!",
        data: {
          email: user.email,
          name: user.name,
          type: user.type,
          token,
          _id: user._id,
        },
      });
    } else {
      return next(sendError(404, "User not found!"));
    }
  } catch (error) {
    console.log("UserController.js login() Error=", error);
    next(sendError(504, "Something went wrong!"));
  }
};

exports.createUser = async (req, res, next) => {
  const { name, email = "", password, type } = req.body;

  if (!name || !email || !password || !type) {
    return next(sendError(422, "Please enter all required fields."));
  }

  if (!EMAIL_VALIDATION.test(email)) {
    return next(sendError(422, "Please enter valid email address."));
  }

  if (password.length < 6) {
    return next(sendError(422, "Password must be atleast 6 characters long."));
  }
  try {
    const user = await User.findOne({ email });

    if (user) return next(sendError(422, "User already exists!"));


    User.create({
      name,
      email,
      password,
      type,
    })
      .then((userData) => {
        const token = generateToken(userData.email, userData.password);

        res.status(201).json({
          message: "User created!",
          data: {
            email: userData.email,
            name: userData.name,
            type: userData.type,
            _id: userData._id,
            token,
          },
        });
      })
      .catch((err) => {
        console.log("auth.js signup Error=", err);
        if (!err.statusCode) {
          err.statusCode = 500;
        }
        next(sendError(500, "Something went wrong!"));
      });
  } catch (error) {
    console.log("SIGNUP ERROR", error);
    next(sendError(500, "Something went wrong!"));
  }
};

exports.fetchWorkers = async (req, res, next) => {
  try {
    const users = await User.find({
      type: { $eq: USER_TYPE.WORKER },
    });
    res.status(200).json({
      message: "Workers fetched successfully!",
      data: users,
    });
  } catch (error) {
    console.log("userController.js fetchWorkers() error=", error);
    next(sendError(422, "Something went wrong"));
  }
};
exports.createService = async (req, res, next) => {
  const {description, serviceName, companyName,address,price,startTime,endTime,userLat,userLong,phoneNumber } = req.body;
console.log(req.body)
  if ( !phoneNumber || !description || !serviceName  || !companyName || !address || !price || !startTime || !endTime || !userLat || !userLong) {
    return next(sendError(422,"Please enter all required fields."));
  }
  if (req.user.type === USER_TYPE.MANAGER) {
    try {
      let serviceID = Math.floor(1000 + Math.random() * 9000);
      const newService = await Service.create({
        description,
        serviceName,
        companyName,
        address,
        price,
        startTime,
        endTime,
        userLat,
        userLong,
        phoneNumber,
        status:2,
        serviceID,
        createdBy:req.user._id,
      });

      res.status(201).json({
        message: "Service created!",
        data: newService,
      });
    } catch (error) {
      console.log("ERROR", error);
      next(sendError(500,"Something went wrong!"));
    }
  } else {
    next(sendError(422,"You are not authorized to create a shift."));
  }
};

exports.getServices = async (req, res, next) => {
  console.log("cum")
  const {isAll} = req.body
  let keyword = {}
  if (!isAll){
    keyword = {createdBy:req.user._id}
  }
  try{
  const services = await Service.find(keyword)
  console.log(services)
res.status(200).json({
  message: "Services fetched!",
  data: services,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.createOrder = async (req, res, next) =>{
const {description, serviceName, companyName,price,bookedTime,bookedDate,phoneNumber,serviceCreator,customerName,address } = req.body;
if ( !phoneNumber || !description || !serviceName  || !companyName || !price || !bookedTime || !bookedDate ||!serviceCreator || !customerName) {
  return next(sendError(422,"Please enter all required fields."));
}
if (req.user.type === USER_TYPE.WORKER) {
  try {
    let status = 1
    let orderID = Math.floor(1000 + Math.random() * 9000);
    const newOrder = await Orders.create({
      description,
      serviceCreator,
      serviceName,
      companyName,
      price,
      bookedTime,
      phoneNumber,
      bookedDate,
      status,
      orderID,
      createdBy:req.user._id,
      customerName,
      address,
    });

    res.status(201).json({
      message: "Appointment created!",
      data: newOrder,
    });
  } catch (error) {
    console.log("ERROR", error);
    next(sendError(500,"Something went wrong!"));
  }
} else {
  next(sendError(422,"You are not authorized to create a shift."));
}
};

exports.getOrders = async (req, res, next) => {
  console.log("cum")
  const {isAll} = req.body
  let keyword = {}
  if (!isAll){
    keyword = {createdBy:req.user._id}
  }
  try{
  const orders = await Orders.find(keyword)
res.status(200).json({
  message: "Orders fetched!",
  data: orders,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.getOrdersForCreator = async (req, res, next) => {
  console.log("here")
  const {isAll,serviceCreator} = req.body
  console.log(isAll)
  let keyword = {}
  if (!isAll){
    let userID = (req.user._id).toString()
    keyword = {serviceCreator:userID}
    console.log(serviceCreator,userID)
  }
  try{
  const orders = await Orders.find(keyword)
res.status(200).json({
  message: "Creater Orders fetched!",
  data: orders,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.updateOrder = async (req, res, next) => {
  console.log("here")
  const {order_ID} = req.body
  console.log(order_ID)
  // console.log(isAll)
  // let keyword = {}
  // if (!isAll){
  //   keyword = {orderID:order_ID}
  //   console.log(order_ID)
  // }
  try{
    const order = await Orders.updateOne(
      {
        orderID: order_ID,
      },
      {
        $set: {
          status: 0,
        },
      }
    );
  // const orders = await Orders.find(keyword)
res.status(200).json({
  message: "Orders Updated!",
  data: order,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.deleteService = async (req, res, next) => {
  console.log("here")
  const {service_ID} = req.body
  console.log(service_ID)
  const query = { serviceID: service_ID };
  try{
    const service = await Service.deleteOne(query)
res.status(200).json({
  message: "Service Deleted!",
  data: service,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.deleteOrder = async (req, res, next) => {
  console.log("here")
  const {order_ID} = req.body
  console.log(order_ID)
  const query = { orderID: order_ID };
  try{
    const service = await Service.deleteOne(query)
res.status(200).json({
  message: "Orders Updated!",
  data: service,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};
exports.addFav = async (req, res, next) => {
  const {serviceID,description, serviceName, companyName,address,price,startTime,endTime,userLat,userLong,phoneNumber } = req.body;
console.log(req.body)
  if ( !serviceID || !phoneNumber || !description || !serviceName  || !companyName || !address || !price || !startTime || !endTime || !userLat || !userLong) {
    return next(sendError(422,"Please enter all required fields."));
  }

  const query = { serviceID: serviceID,createdBy:req.user._id, };
  const fav = await favService.find(query);
  console.log(fav.length)
  if (fav.length > 0){
    return next(sendError(422,"Already Added To Favorite"));
  }

  if (req.user.type === USER_TYPE.WORKER) {
    try {
      const newFavorite = await favService.create({
        description,
        serviceName,
        companyName,
        address,
        price,
        startTime,
        endTime,
        userLat,
        userLong,
        phoneNumber,
        status:2,
        serviceID,
        createdBy:req.user._id,
      });

      res.status(201).json({
        message: "Added To Favorites created!",
        data: newFavorite,
      });
    } catch (error) {
      console.log("ERROR", error);
      next(sendError(500,"Something went wrong!"));
    }
  } else {
    next(sendError(422,"You are not authorized to create a Fav."));
  }
};

exports.getFav = async (req, res, next) => {
  console.log("cum")
  const {isAll} = req.body
  let keyword = {}
  if (!isAll){
    keyword = {createdBy:req.user._id}
  }
  try{
  const favorite = await favService.find(keyword)
res.status(200).json({
  message: "Favorites fetched!",
  data: favorite,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};

exports.deleteFav = async (req, res, next) => {
  console.log("here")
  const {service_ID} = req.body
  console.log(service_ID)
  const query = { serviceID: service_ID,createdBy:req.user._id};
  try{
    const favortie = await favService.deleteOne(query)
res.status(200).json({
  message: "Favorite Deleted!",
  data: favortie,
});
} catch (error) {
console.log("ERROR", error);
next(sendError(500,'Something went wrong!'))
}
};