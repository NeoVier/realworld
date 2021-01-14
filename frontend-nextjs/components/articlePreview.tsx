import Link from "next/link";
import Article from "types/Article";

type Props = { article: Article };

const ArticlePreview = ({ article }: Props) => {
  return (
    <div className="article-preview">
      <div className="article-meta">
        <Link href="">
          {/* TODO */}
          <a>
            <img src={article.author.image ?? ""} />
          </a>
        </Link>

        <div className="info">
          <Link href="">
            {/* TODO */}
            <a className="author">{article.author.username}</a>
          </Link>
          <span className="date">January 20th</span> {/* TODO */}
        </div>

        <button className="btn btn-outline-primary btn-sm pull-xs-right">
          <i className="ion-heart"></i> {article.favoritesCount}
        </button>
      </div>

      <Link href="">
        {/* TODO */}
        <a className="preview-link">
          <h1>{article.title}</h1>
          <p>{article.description}</p>
          <span>Read more...</span>
          <ul className="tag-list">
            {article.tagList.map((tag) => (
              <li className="tag-default tag-pill tag-outline">{tag}</li>
            ))}
          </ul>
        </a>
      </Link>
    </div>
  );
};

export default ArticlePreview;
