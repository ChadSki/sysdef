{ ... }:
{
  guestConfig = {
    services = {
      code-server = {
        enable = true;
        auth = "none";
        host = "code-server.mydomain.test";
      };
    };
  };

  hostConfig = {};
}
