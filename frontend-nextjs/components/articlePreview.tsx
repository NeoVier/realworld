import Link from "next/link";
import Article from "types/Article";
import ArticleMeta from "./articleMeta";

type Props = { article: Article };

const ArticlePreview = ({ article }: Props) => {
  return (
    <div className="article-preview">
      <ArticleMeta article={article} variant="small" />

      <Link href={`/article/${article.slug}`}>
        <a className="preview-link">
          <h1>{article.title}</h1>
          <p>{article.description}</p>
          <span>Read more...</span>
          <ul className="tag-list">
            {article.tagList.map((tag, idx) => (
              <li className="tag-default tag-pill tag-outline" key={idx}>
                {tag}
              </li>
            ))}
          </ul>
        </a>
      </Link>
    </div>
  );
};

export default ArticlePreview;
