const mongoose = require("mongoose");

const { SHIFT_STATUS } = require("../shared/constants");

const Schema = mongoose.Schema;

const serviceSchema = new Schema(
  {
    description: {
      type: String,
      required: true,
    },
    serviceName: {
        type: String,
        required: true,
    },
    companyName: {
        type: String,
        required: true,
    },
    address: {
        type: String,
        // required: true,
    },
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: "Auth",
      required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    endTime: {
        type: String,
        // required: true,
    },
    startTime: {
        type: String,
        // required: true,
    },
    bookedTime: {
        type: String,
        // required: true,
    },
    userLat: {
        type: Number,
        // required: true,
    }, 
    userLong: {
        type: Number,
        // required: true,
    },
    phoneNumber: {
        type: Number,
        required: true,
    },
    bookedDate: {
        type: String,
        // required: true,
    },
    status: {
        type: Number,
        // required: true,
    },
    serviceID: {
        type: Number,
        required: true,
    },
  },
  {
    timestamps: true,
  }
);
module.exports = mongoose.model("Service", serviceSchema);
