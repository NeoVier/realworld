import Article from "types/Article";
import ArticlePreview from "./articlePreview";

type Props = {
  articles: Article[];
};

const ArticleList = ({ articles }: Props) =>
  articles.length === 0 ? (
    <div className="article-preview">No articles are here... yet.</div>
  ) : (
    <>
      {articles.map((article) => (
        <ArticlePreview article={article} />
      ))}
    </>
  );

export default ArticleList;
