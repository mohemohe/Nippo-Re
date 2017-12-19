module.exports = {
  password: async (req, res) => {
    const username = req.access_token.username;

    if (!req.body.password) {
      return res.badRequest({});
    }

    let user;
    try {
      user = await User.update({
        username
      }, {
        password: req.body.password,
      });
    } catch(e) {
      sails.log.error(e);
    }

    if (!user) {
      return res.serverError({});
    } else {
      return res.ok({});
    }
  },
};
