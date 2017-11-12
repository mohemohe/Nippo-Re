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
    }
  </style>
</app>
