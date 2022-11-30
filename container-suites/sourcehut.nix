{ ... }:
{
  guestConfig = {
    services = {
      sourcehut = {
        enable = true;
      };
    };
  };

  hostConfig = { };
}
