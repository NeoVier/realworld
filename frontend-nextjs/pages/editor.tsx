import EditArticle from "components/editArticle";
import Footer from "components/footer";
import Navbar from "components/navbar";
import Profile from "types/Profile";

type Props = { author: Profile };

const Editor = ({ author }: Props) => {
  const emptyArticle = {
    slug: "",
    title: "",
    description: "",
    body: "",
    tagList: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    favorited: false,
    favoritesCount: 0,
    author: author,
  };

  return (
    <>
      <Navbar activePage="editor" />
      <EditArticle article={emptyArticle} />
      <Footer />
    </>
  );
};

export default Editor;
