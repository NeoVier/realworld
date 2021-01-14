import Link from "next/link";
import Profile from "types/Profile";
import User from "types/User";

type Props = {
  author: Profile | User;
  variant?: Variant;
};

type Variant = "default" | "clickable" | "comment";

const AuthorImage = ({ author, variant = "default" }: Props) => {
  switch (variant) {
    case "default":
      return <img src={author.image} className="user-img" />;
    case "clickable":
      return (
        <Link href={`/profile/${author.username}`}>
          <a>
            <img src={author.image} />
          </a>
        </Link>
      );
    case "comment":
      return (
        <Link href="">
          <a className="comment-author">
            <img src={author.image} className="comment-author-img" />
          </a>
        </Link>
      );
  }
};

export default AuthorImage;
