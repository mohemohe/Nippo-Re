<page-signup>
  <div class="container">
    <div class="row">
      <form class="col s12">
        <div class="row">
          <div class="input-field col s12">
            <input id="username" type="text" class="validate">
            <label for="username">ユーザー名</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <input id="password" type="password" class="validate">
            <label for="password">パスワード</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <input id="password2" type="password" class="validate">
            <label for="password2">パスワード（確認）</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <button class="btn waves-effect waves-light right" onclick="{ signup }">新規登録
              <i class="material-icons right">send</i>
            </button>
          </div>
        </div>
      </form>
      <div class="row">
        <div class="col s12">
          <p>{ authInfo }</p>
        </div>
      </div>
    </div>
  </div>

  <style>
    input {
      font-size: 16px !important;
    }
  </style>

  <script>
    import axios from 'axios';
    axios.defaults.withCredentials = true;
    axios.defaults.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': $("meta[name='csrf-token']").attr('content'),
    };

    const self = this;

    self.authInfo = null;

    signup() {
      const username = $("#username").val();
      const password = $("#password").val();
      const confirmPassword = $("#password2").val();


      if (password !== confirmPassword) {
        self.authInfo = 'パスワードが一致していません';
        self.update();
        return;
      }

      EventWorker.event.trigger('apiSignup:raise', username, password);
    }

    onSignupError() {
      self.authInfo = '新規登録に失敗しました';
      self.update();
    }

    this.on('mount', () => {
      EventWorker.event.on('apiSignup:error', self.onSignupError);
    });

    this.on('unmount', () => {
      EventWorker.event.off('apiLogin:error', self.onSignupError);
    });
  </script>
</page-signup>
