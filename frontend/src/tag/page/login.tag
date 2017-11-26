<page-login>
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
            <a href="#/signup" class="waves-effect waves-light btn">新規登録</a>
            <button class="btn waves-effect waves-light right" onclick="{ login }">ログイン
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
    const self = this;

    self.authInfo = null;

    login() {
      const username = $("#username").val();
      const password = $("#password").val();
      EventWorker.event.trigger('apiLogin:raise', username, password);
    }

    onLoginError() {
      self.authInfo = 'ログインに失敗しました';
      self.update();
    }

    this.on('mount', () => {
      EventWorker.event.on('apiLogin:error', self.onLoginError);
    });

    this.on('unmount', () => {
      EventWorker.event.off('apiLogin:error', self.onLoginError);
    });

  </script>
</page-login>
