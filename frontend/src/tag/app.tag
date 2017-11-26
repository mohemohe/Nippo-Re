<app>
  <common-header/>

  <main>
    <route/>
  </main>

  <style>
    app {
      display: flex;
      -webkit-flex-direction: column;
      -ms-flex-direction: column;
      flex-direction: column;
      min-height: 100vh;
    }

    app > * {
      display: block;
    }

    main {
      flex: 1;
      margin-top: 1rem;
    }
  </style>

  <script>
    const self = this;

    EventWorker.event.on('hashChanged', (hash) => {
      console.info(hash);
    });

    EventWorker.event.on('apiLogin:done', () => {
      self.update();
      location.href = '#/';
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
