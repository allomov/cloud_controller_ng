require "spec_helper"

module CloudController
  describe BlobstoreUrlGenerator do
    let(:blobstore_host) do
      "api.example.com"
    end

    let(:blobstore_port) do
      9292
    end

    let(:connection_options) do
      {
        blobstore_host: blobstore_host,
        blobstore_port: blobstore_port,
        user: "username",
        password: "password",
      }
    end

    let(:package_blobstore) { double(local?: true) }
    let(:buildpack_cache_blobstore) { double(local?: true) }
    let(:admin_buildpack_blobstore) { double(local?: true) }
    let(:droplet_blobstore) { double(local?: true) }

    subject(:blobstore_url_generator) do
      BlobstoreUrlGenerator.new(connection_options,
                                package_blobstore,
                                buildpack_cache_blobstore,
                                admin_buildpack_blobstore,
                                droplet_blobstore)
    end

    let(:app) { VCAP::CloudController::App.make }

    context "downloads" do
      describe "app package" do
        context "when the packages are stored on local blobstore" do
          it "gives a local URI to the blobstore host/port" do
            uri = URI.parse(subject.app_package_download_url(app))
            expect(uri.host).to eql blobstore_host
            expect(uri.port).to eql blobstore_port
            expect(uri.user).to eql "username"
            expect(uri.password).to eql "password"
            expect(uri.path).to eql "/staging/apps/#{app.guid}"
          end
        end

        context "when the packages are stored remotely" do
          let(:package_blobstore) { double(local?: false) }

          it "gives out signed url to remote blobstore for appbits" do
            remote_uri = "http://s3.example.com/signed"

            package_blobstore.should_receive(:download_uri).with(app.guid).and_return(remote_uri)

            expect(subject.app_package_download_url(app)).to eql(remote_uri)
          end
        end
      end

      describe "buildpack cache" do
        context "when the caches are stored on local blobstore" do
          it "gives a local URI to the blobstore host/port" do
            uri = URI.parse(subject.buildpack_cache_download_url(app))
            expect(uri.host).to eql blobstore_host
            expect(uri.port).to eql blobstore_port
            expect(uri.user).to eql "username"
            expect(uri.password).to eql "password"
            expect(uri.path).to eql "/staging/buildpack_cache/#{app.guid}/download"
          end
        end

        context "when the packages are stored remotely" do
          let(:buildpack_cache_blobstore) { double(local?: false) }

          it "gives out signed url to remote blobstore for appbits" do
            remote_uri = "http://s3.example.com/signed"

            buildpack_cache_blobstore.should_receive(:download_uri).with(app.guid).and_return(remote_uri)

            expect(subject.buildpack_cache_download_url(app)).to eql(remote_uri)
          end
        end
      end

      context "admin buildpacks" do
        let(:buildpack) { VCAP::CloudController::Buildpack.make }

        context "when the admin buildpacks are stored on local blobstore" do
          it "gives a local URI to the blobstore host/port" do
            uri = URI.parse(subject.admin_buildpack_download_url(buildpack))
            expect(uri.host).to eql blobstore_host
            expect(uri.port).to eql blobstore_port
            expect(uri.user).to eql "username"
            expect(uri.password).to eql "password"
            expect(uri.path).to eql "/buildpacks/#{buildpack.guid}/download"
          end
        end

        context "when the buildpack are stored remotely" do
          let(:admin_buildpack_blobstore) { double(local?: false) }

          it "gives out signed url to remote blobstore for appbits" do
            remote_uri = "http://s3.example.com/signed"
            admin_buildpack_blobstore.should_receive(:download_uri).with(buildpack.key).and_return(remote_uri)
            expect(subject.admin_buildpack_download_url(buildpack)).to eql(remote_uri)
          end
        end
      end

      context "droplets" do
        let(:app) { VCAP::CloudController::App.make }

        context "when the droplets are stored on local blobstore" do
          it "gives a local URI to the blobstore host/port" do
            uri = URI.parse(subject.droplet_download_url(app))
            expect(uri.host).to eql blobstore_host
            expect(uri.port).to eql blobstore_port
            expect(uri.user).to eql "username"
            expect(uri.password).to eql "password"
            expect(uri.path).to eql "/staging/droplets/#{app.guid}/download"
          end
        end

        context "when the buildpack are stored remotely" do
          let(:droplet_file) { double("file") }
          let(:droplet_blobstore) { double(local?: false, file: droplet_file) }

          it "gives out signed url to remote blobstore for appbits" do
            remote_uri = "http://s3.example.com/signed"
            droplet_blobstore.should_receive(:download_uri_for_file).with(droplet_file).and_return(remote_uri)
            expect(subject.droplet_download_url(app)).to eql(remote_uri)
          end
        end
      end
    end

    context "uploads" do
      it "gives out url for droplets" do
        uri = URI.parse(subject.droplet_upload_url(app))
        expect(uri.host).to eql blobstore_host
        expect(uri.port).to eql blobstore_port
        expect(uri.user).to eql "username"
        expect(uri.password).to eql "password"
        expect(uri.path).to eql "/staging/droplets/#{app.guid}/upload"
      end


      it "gives out url for buidpack cache" do
        uri = URI.parse(subject.buildpack_cache_upload_url(app))
        expect(uri.host).to eql blobstore_host
        expect(uri.port).to eql blobstore_port
        expect(uri.user).to eql "username"
        expect(uri.password).to eql "password"
        expect(uri.path).to eql "/staging/buildpack_cache/#{app.guid}/upload"
      end
    end
  end
end
