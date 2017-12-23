<app>
  <common-header/>

  <main>
    <route/>
  </main>

  <style>
    app {
      height: 100vh;
    }

    app > * {
      display: block;
    }

    main {
      position: absolute;
      top: 0;
      height: 100vh;
      width: 100vw;
      padding-top: 78px;
      box-sizing: border-box;
    }
  </style>

  <script>
    import {EventWorker} from "../js/eventWorker";

    const self = this;

    EventWorker.event.on('hashChanged', (hash) => {
      console.info(hash);
    });

    EventWorker.event.on('apiLogin:done', () => {
      self.update();
      location.href = '#/';
    });

    EventWorker.event.on('showToast', (text, timeout = 4000) => {
      const $toastContent = $(`<span>${text}</span>`).add($('<button class="btn-flat toast-action" onclick="EventWorker.event.trigger(`closeToast`, this)">閉じる</button>'));
      return Materialize.toast($toastContent, timeout);
    });

    EventWorker.event.on('closeToast', (event) => {
      const toastElement = event.parentElement;
      const toastInstance = toastElement.M_Toast;
      toastInstance.remove();
    });

    onRefreshTokenError() {
      EventWorker.event.trigger('apiLogout:raise');
    }

    this.on('mount', () => {
      if(localStorage.auth_info) {
        EventWorker.event.on('apiRefreshToken:error', self.onRefreshTokenError);
        EventWorker.event.trigger('apiRefreshToken:raise');
      }
    });
  </script>
</app>
