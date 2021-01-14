import ArticleMeta from "components/articleMeta";
import ViewComment from "components/comment";
import EditComment from "components/editComment";
import Footer from "components/footer";
import Navbar from "components/navbar";
import { articles, currentUser } from "mockData";
import Article from "types/Article";
import Comment from "types/Comment";

type Props = {
  article: Article;
};

const ArticlePage = ({ article = articles[0] }: Props) => {
  const comments: Comment[] = [];
  return (
    <>
      <Navbar activePage="article" />

      <div className="article-page">
        <div className="banner">
          <div className="container">
            <h1>{article.title}</h1>

            <ArticleMeta article={article} />
          </div>
        </div>

        <div className="container page">
          <div className="row article-content">
            <div className="col-md-12">
              <p>{article.body}</p>
            </div>
          </div>

          <hr />

          <div className="article-actions">
            <ArticleMeta article={article} />
          </div>

          <div className="row">
            <div className="col-xs-12 col-md-8 offset-md-2">
              <EditComment user={currentUser} />

              {comments.map((comment) => (
                <ViewComment comment={comment} key={comment.id} />
              ))}
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
};

export default ArticlePage;
