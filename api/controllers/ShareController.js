module.exports = {
  get: async (req, res) => {
    const user = req.param('user');
    const hash = req.param('hash');

    let result;

    let nippo;
    try {
      nippo = await Nippo.findOne({
        username: user,
        sharedHash: hash,
      });
    } catch (e) {
      result = {
        status: 1,
        result: [],
      };
    }

    if (!nippo) {
      result = {
        status: 1,
        result: [],
      };
    } else {
      nippo.id = nippo.nippoId;
      if (nippo.sharedPassword && nippo.sharedPassword !== '') {
        nippo.isEncrypted = true;
      } else {
        nippo.isEncrypted = false;
      }

      delete nippo.username;
      delete nippo.nippoId;
      delete nippo.title;
      delete nippo.body;
      delete nippo.isShared;
      delete nippo.sharedPassword;
      delete nippo.sharedHash;
      delete nippo.createdAt;
      delete nippo.updatedAt;

      result = {
        status: 0,
        result: nippo,
      }
    }

    res.ok(result);
  },
};

