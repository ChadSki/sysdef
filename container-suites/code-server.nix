{ ... }:
{
  guestConfig = {
    services = {
      code-server = {
        enable = true;
        hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$wst5qhbgk2lu1ih4dmuxvg$ls1alrvdiwtvzhwnzcm1dugg+5dto3dt1d5v9xtlws4";
      };
    };
  };

  hostConfig = {};
}
