<page-create>
  <common-edit />

  <script>
    const self = this;

    this.on('before-unmount', () => {
      self.tags['common-edit'].dispose();
    });
  </script>
</page-create>
