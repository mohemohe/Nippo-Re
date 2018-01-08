<page-signup>
  <div class="container">
    <common-terms-of-service/>

    <div class="row">
      <p onclick="{ this.onChangeIsAgree }">
        <input type="checkbox" class="filled-in" id="is-agree" checked="{ checked: this.isAgree }" />
        <label for="is-agree">利用規約に同意</label>
      </p>
      <p>
        同意しない場合でもオフラインモードで引き続きご利用頂けます
      </p>
    </div>

    <div class="row">
      <form class="col s12">
        <div class="row">
          <div class="input-field col s12">
            <input id="username" type="text" class="validate" disabled="{ disabled: !this.isAgree }">
            <label for="username">ユーザー名</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <input id="password" type="password" class="validate" disabled="{ disabled: !this.isAgree }">
            <label for="password">パスワード</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <input id="password2" type="password" class="validate" disabled="{ disabled: !this.isAgree }">
            <label for="password2">パスワード（確認）</label>
          </div>
        </div>
        <div class="row">
          <div class="input-field col s12">
            <button class="btn waves-effect waves-light right { disabled: !this.isAgree }" onclick="{ signup }">新規登録
              <i class="material-icons right">send</i>
            </button>
          </div>
        </div>
      </form>
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

    self.isAgree = false;

    signup() {
      const username = $("#username").val();
      const password = $("#password").val();
      const confirmPassword = $("#password2").val();


      let isError = false;
      if (username === '') {
        isError = true;
        EventWorker.event.trigger('showToast', 'ユーザー名を指定してください');
      }

      if (password === '') {
        isError = true;
        EventWorker.event.trigger('showToast', 'パスワードを指定してください');
      }

      if (password !== confirmPassword) {
        isError = true;
        EventWorker.event.trigger('showToast', 'パスワードが一致していません');
      }

      if (isError) {
        return;
      }

      EventWorker.event.trigger('apiSignup:raise', username, password);
    }

    onSignupError() {
      EventWorker.event.trigger('showToast', 'ユーザー登録に失敗しました');
    }

    onChangeIsAgree() {
      self.isAgree = document.querySelector('#is-agree').checked;
      self.update();
    }

    this.on('mount', () => {
      EventWorker.event.on('apiSignup:error', self.onSignupError);
    });

    this.on('before-unmount', () => {
      EventWorker.event.off('apiSignup:error', self.onSignupError);
    });
  </script>
</page-signup>
