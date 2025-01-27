'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  User.init({
    id: {
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
      type: DataTypes.INTEGER,
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false, // Ensure firstName is not null if required
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false, // Ensure lastName is not null if required
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false, // Ensure email is not null
      unique: true, // Add unique constraint if necessary
      validate: {
        isEmail: true, // Validate email format
      },
    },
    createdAt: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    updatedAt: {
      type: DataTypes.DATE,
      allowNull: false,
    }
  }, {
    sequelize,
    modelName: 'User',
    tableName: 'Users',
  });
  return User;
};