import User from "types/User";

type Props = { user: User };

const EditComment = ({ user }: Props) => {
  return (
    <form className="card comment-form">
      <div className="card-block">
        <textarea
          rows={3}
          className="form-control"
          placeholder="Write a comment..."
        ></textarea>
      </div>
      <div className="card-footer">
        <img src={user.image} className="comment-author-img" />
        <button className="btn btn-sm btn-primary">Post Comment</button>
      </div>
    </form>
  );
};

export default EditComment;
