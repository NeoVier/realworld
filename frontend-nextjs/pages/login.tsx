import Footer from "components/footer";
import Navbar from "components/navbar";
import Link from "next/link";
import { useState } from "react";

type FormInfo = {
  errors: string[];
  email: string;
  password: string;
};

const Login = () => {
  const [formInfo, setFormInfo] = useState<FormInfo>({
    errors: [],
    email: "",
    password: "",
  });

  const handleEmailChange = (event: React.FormEvent<HTMLInputElement>) => {
    setFormInfo({ ...formInfo, email: event.currentTarget.value });
  };

  const handlePasswordChange = (event: React.FormEvent<HTMLInputElement>) => {
    setFormInfo({ ...formInfo, password: event.currentTarget.value });
  };

  const handleSubmit = (event: React.FormEvent<HTMLButtonElement>) => {
    console.log(formInfo);
    event.preventDefault();
  };

  return (
    <>
      <Navbar activePage="login" />
      <div className="auth-page">
        <div className="container page">
          <div className="row">
            <div className="col-md-6 offset-md-3 col-xs-12">
              <h1 className="text-xs-center">Sign in</h1>
              <p className="text-xs-center">
                <Link href="/register">
                  <a>Need an account?</a>
                </Link>
              </p>

              <ul className="error-messages">
                {formInfo.errors.map((error, idx) => (
                  <li key={idx}>{error}</li>
                ))}
              </ul>

              <form>
                <fieldset className="form-group">
                  <input
                    className="form-control form-control-lg"
                    type="text"
                    placeholder="Email"
                    onChange={handleEmailChange}
                  />
                </fieldset>

                <fieldset className="form-group">
                  <input
                    className="form-control form-control-lg"
                    type="password"
                    placeholder="Password"
                    onChange={handlePasswordChange}
                  />
                </fieldset>

                <button
                  className="btn btn-lg btn-primary pull-xs-right"
                  onClick={handleSubmit}
                >
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
