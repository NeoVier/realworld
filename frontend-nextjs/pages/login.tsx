import Footer from "components/footer";
import Navbar from "components/navbar";
import Link from "next/link";

const Login = () => {
  const errors: string[] = [];

  return (
    <>
      <Navbar activePage="login" />
      <div className="auth-page">
        <div className="container page">
          <div className="row">
            <div className="col-md-6 offset-md-3 col-xs-12">
              <h1 className="text-xs-center">Sign in</h1>
              <p className="text-xs-center">
                <Link href="">
                  {/* TODO */}
                  <a>Need an account?</a>
                </Link>
              </p>

              <ul className="error-messages">
                {errors.map((error) => (
                  <li>{error}</li>
                ))}
              </ul>

              <form>
                <fieldset className="form-group">
                  <input
                    className="form-control form-control-lg"
                    type="text"
                    placeholder="Email"
                  />
                </fieldset>

                <fieldset className="form-group">
                  <input
                    className="form-control form-control-lg"
                    type="password"
                    placeholder="Password"
                  />
                </fieldset>

                <button className="btn btn-lg btn-primary pull-xs-right">
                  Sign in
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </>
  );
};

export default Login;
