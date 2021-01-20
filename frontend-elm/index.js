import { Elm } from "./src/Main.elm";

const USER_TOKEN = "userToken";

const userToken = localStorage.getItem(USER_TOKEN);

const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: {
    dimmensions: { width: window.innerWidth, height: window.innerHeight },
    userToken,
  },
});

app.ports.sendUser.subscribe(function (user) {
  localStorage.setItem(USER_TOKEN, user.token);
});

app.ports.logOut.subscribe(function () {
  localStorage.removeItem(USER_TOKEN);
});
