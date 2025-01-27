var express = require('express');
var router = express.Router();
var db = require('../models');

/* GET health check */
router.get('/', async function (req, res, next) {
    try {
        await db.sequelize.authenticate();
        
        res.status(200).json({
            status: 'success',
            message: 'Database connection is healthy'
        });
    } catch (error) {
     
        res.status(500).json({
            status: 'error',
            message: 'Unable to connect to the database',
            details: error.message
        });
    }
});

module.exports = router;
