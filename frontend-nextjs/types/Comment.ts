import Profile from "./Profile";

type Comment = {
  id: number;
  createdAt: Date;
  updatedAt: Date;
  body: string;
  author: Profile;
};

export default Comment;
