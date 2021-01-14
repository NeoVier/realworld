import EditArticle from "components/editArticle";
import Footer from "components/footer";
import Navbar from "components/navbar";
import Article from "types/Article";

type Props = { article: Article };

const Editor = ({ article }: Props) => {
  return (
    <>
      <Navbar activePage="editor" />
      <EditArticle article={article} />
      <Footer />
    </>
  );
};

export default Editor;
