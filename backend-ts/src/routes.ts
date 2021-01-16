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
    route: "/api/user",
    controller: UserController,
    action: "getUser",
  },
  {
    method: "put",
    route: "/api/user",
    controller: UserController,
    action: "updateUser",
  },
  {
    method: "get",
    route: "/api/profiles/:username",
    controller: UserController,
    action: "getProfile",
  },
  {
    method: "post",
    route: "/api/profiles/:username/follow",
    controller: UserController,
    action: "followUser",
  },
  {
    method: "delete",
    route: "/api/profiles/:username/follow",
    controller: UserController,
    action: "unfollowUser",
  },

  {
    method: "get",
    route: "/api/articles/:slug",
    controller: ArticleController,
    action: "one",
  },
  // {
  //   method: "get",
  //   route: "/api/articles",
  //   controller: ArticleController,
  //   action: "list",
  // },
  {
    method: "post",
    route: "/api/articles",
    controller: ArticleController,
    action: "create",
  },

  {
    method: "get",
    route: "/api/tags",
    controller: TagController,
    action: "all",
  },
];
