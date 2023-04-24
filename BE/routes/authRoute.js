const express = require("express");

const authController = require("../controllers/authController");
const isAuth = require("../middleware/isAuth");


const router = express.Router();

// POST /auth/login
router.post("/login", authController.login);




//POST /auth/createService
router.post("/createService",isAuth,authController.createService);

//POST /auth/createOrder
router.post("/createOrder",isAuth,authController.createOrder);

//GET => /auth/getServices
router.post("/getServices", isAuth, authController.getServices);

//POST => /auth/deleteService
router.post("/deleteService", isAuth, authController.deleteService);

//GET => /auth/getOrders
router.post("/getOrders", isAuth, authController.getOrders);

//POST => /auth/updateOrder
router.post("/updateOrder", isAuth, authController.updateOrder);

//POST => /auth/deleteOrder
router.post("/deleteOrder", isAuth, authController.deleteOrder);

//GET => /auth/getOrdersForCreator
router.post("/getOrdersForCreator", isAuth, authController.getOrdersForCreator);

//POST => /auth/addFav
router.post("/addFav", isAuth, authController.addFav);

//POST => /auth/addFav
router.post("/getFav", isAuth, authController.getFav);

//POST => /auth/deleteFav
router.post("/deleteFav", isAuth, authController.deleteFav);




//POST => /auth/createUser
router.post("/createUser", authController.createUser);

//GET => /auth/fetchWorkers
router.get("/fetchWorkers", isAuth, authController.fetchWorkers);

module.exports = router;
