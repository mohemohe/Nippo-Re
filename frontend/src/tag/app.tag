<app>
  <common-header/>

  <main>
    <route/>
  </main>

  <common-footer/>

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
      overflow-x: hidden;
      -webkit-overflow-scrolling: touch !important;
    }

    html.edit main {
      -webkit-overflow-scrolling: auto !important;
    }
  </style>

  <script>
    import moment from 'moment';
    import {EventWorker} from "../js/eventWorker";

    const self = this;

    this.lastToastMessage = '';
    this.lastToastTime = moment();

    EventWorker.event.on('hashChanged', (hash) => {
      console.info(hash);
    });

    EventWorker.event.on('apiLogin:done', () => {
      self.update();
      location.href = '#/';
    });

    EventWorker.event.on('showToast', (text, timeout = 4000) => {
      if (self.lastToastMessage === text && moment(self.lastToastTime).add(50, 'ms') > moment()) {
        return;
      }
      self.lastToastMessage = text;
      self.lastToastTime = moment();

      const $toastContent = $(`<span>${text}</span>`).add($('<button class="btn-flat toast-action" onclick="EventWorker.event.trigger(`closeToast`, this)"><i class="material-icons left" style="color:rgb(211,99,103)">close</i></button>'));
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
