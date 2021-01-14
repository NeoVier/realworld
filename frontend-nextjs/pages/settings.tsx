import Footer from "components/footer";
import Navbar from "components/navbar";

const Settings = () => {
  return (
    <>
      <Navbar activePage="settings" />
      <div className="settings-page">
        <div className="container-page">
          <div className="row">
            <div className="col-md-6 offset-md-3 col-xs-12">
              <h1 className="text-xs-center">Your Settings</h1>

              <form>
                <fieldset className="form-group">
                  <input
                    type="text"
                    className="form-control"
                    placeholder="URL of profile picture"
                  />
                </fieldset>

                <fieldset className="form-group">
                  <input
                    type="text"
                    className="form-control form-control-lg"
                    placeholder="Your Name"
                  />
                </fieldset>
                <fieldset className="form-group">
                  <textarea
                    className="form-control form-control-lg"
                    rows={8}
                    placeholder="Short bio about you"
                  />
                </fieldset>
                <fieldset className="form-group">
                  <input
                    type="text"
                    className="form-control form-control-lg"
                    placeholder="Email"
                  />
                </fieldset>
                <fieldset className="form-group">
                  <input
                    type="password"
                    className="form-control form-control-lg"
                    placeholder="Password"
                  />
                </fieldset>

                <button className="btn btn-lg btn-primary pull-xs-right">
                  Update Settings
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

export default Settings;
