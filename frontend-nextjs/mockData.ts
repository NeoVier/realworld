import Article from "types/Article";
import Profile from "types/Profile";
import User from "types/User";

export const users: User[] = [
  {
    email: "henrique.buss@hotmail.com",
    token: "",
    username: "neovier",
    bio: "Functional programmer",
  },
];

export const profiles: Profile[] = [
  {
    username: "neovier",
    bio: "Functional programmer",
    image: "http://i.imgur.com/N4VcUeJ.jpg",
    following: false,
  },
];

export const articles: Article[] = [
  {
    slug: "first-article",
    title: "First Title",
    description: "First description",
    body: "First body",
    tagList: ["First tag", "second tag"],
    createdAt: new Date(),
    updatedAt: new Date(),
    favorited: false,
    favoritesCount: 0,
    author: profiles[0],
  },
];
export const defaultProfileImg =
  "https://static.productionready.io/images/smiley-cyrus.jpg";

export const popularTags: string[] = [
  "programming",
  "javascript",
  "emberjs",
  "angularjs",
  "react",
  "mean",
  "node",
  "rails",
];
