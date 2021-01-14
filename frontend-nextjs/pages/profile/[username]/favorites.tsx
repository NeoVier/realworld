import Profile from "components/profilePage";
import { articles, users } from "mockData";

const DefaultProfile = () => {
  return <Profile user={users[0]} articles={articles} favorites />;
};

export default DefaultProfile;
