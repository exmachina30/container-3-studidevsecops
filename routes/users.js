var express = require('express');
var router = express.Router();
var db = require('../models');

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    const users = await db.User.findAll({
      where: {
        id: {
          [db.Sequelize.Op.between]: [0, 100]
        }
      }
    }); 

    console.log('Users fetched:', users);
    
    if (users.length === 0) {
      return res.status(404).json({ message: 'No users found' }); // Handle empty result set
    }

    res.json(users); // Use `json` to properly format the response as JSON
  } catch (error) {
    console.error('Error fetching users:', error);
    console.log(db)
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
