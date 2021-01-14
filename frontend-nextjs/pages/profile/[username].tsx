import ArticleList from "components/articleList";
import Footer from "components/footer";
import Navbar from "components/navbar";
import { articles, defaultProfileImg, users } from "mockData";
import Link from "next/link";

const Profile = () => {
  const user = users[0];

  return (
    <>
      <Navbar activePage="profile" />

      <div className="profile-page">
        <div className="user-info">
          <div className="container">
            <div className="row">
              <div className="col-xs-12 col-md-10 offset-md-1">
                <img
                  src={user.image ?? defaultProfileImg}
                  className="user-img"
                />
                <h4>{user.username}</h4>
                <p>{user.bio}</p>
                <button className="btn btn-sm btn-outline-secondary action-btn">
                  <i className="ion-plus-round"></i>
                  &nbsp; Follow {user.username}
                </button>
              </div>
            </div>
          </div>
        </div>

        <div className="container">
          <div className="row">
            <div className="col-xs-12 col-md-10 offset-md-1">
              <div className="articles-toggle">
                <ul className="nav nav-pills outline-active">
                  <li className="nav-item">
                    <Link href="">
                      {/* TODO */}
                      <a className="nav-link active">My Articles</a>
                    </Link>
                  </li>

                  <li className="nav-item">
                    <Link href="">
                      {/* TODO */}
                      <a className="nav-link">Favorited Articles</a>
                    </Link>
                  </li>
                </ul>
              </div>

              <ArticleList articles={articles} />
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
};

export default Profile;
