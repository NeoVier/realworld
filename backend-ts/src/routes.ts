import ArticleController from "./controller/ArticleController";
import TagController from "./controller/TagController";
import UserController from "./controller/UserController";

export const Routes = [
  {
    method: "post",
    route: "/api/users",
    controller: UserController,
    action: "register",
  },
  {
    method: "post",
    route: "/api/users/login",
    controller: UserController,
    action: "login",
  },

  {
    method: "get",
    route: "/api/articles/:slug",
    controller: ArticleController,
    action: "one",
  },

  {
    method: "get",
    route: "/api/tags",
    controller: TagController,
    action: "all",
  },
];
