import User from '../models/user.model'

const createUser = async (req, res) => {
    try {
        const user = await User.create(req.body);
        res.json({user: user._id});
    }
    catch (e) {
        res.json({errors: {
            email : "",
            password : ""
        }})
    }
};

module.exports = createUser