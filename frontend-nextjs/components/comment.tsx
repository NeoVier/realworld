import Link from "next/link";
import Comment from "types/Comment";
import AuthorImage from "./authorImage";

type Props = {
  comment: Comment;
};

const ViewComment = ({ comment }: Props) => {
  return (
    <div className="card">
      <div className="card-block">
        <p className="card-text">{comment.body}</p>
      </div>
      <div className="card-footer">
        <AuthorImage author={comment.author} variant="comment" />
        &nbsp;
        <Link href={`/profile/${comment.author.username}`}>
          <a className="comment-author">{comment.author.username}</a>
        </Link>
        {/* TODO */}
        <span className="date-posted">Dec 29th</span>
      </div>
    </div>
  );
};

export default ViewComment;
