module Api
  module V1
    
    #class UwactivestorageController < ApplicationController
    class UwactivestorageController < ActiveStorage::DirectUploadsController

      protect_from_forgery with: :exception
      skip_before_action :verify_authenticity_token
      #before_action :doorkeeper_authorize! # this is doorkeeper specific, but you can use any token authentication scheme here

      def index
        signedid = 'No data available'
        render json: {status: 'SUCCESS', message: 'TestOnly', signed_id: signedid }, status: :ok
      end
      
      def create

        # Step 5.1: Get the parameter data from the frontend
        pfilename = params[:public_id] #params[:filename]
        pchecksum = params[:checksum]
        pbytesize = params[:byte_size]
        pcontenttype = params[:content_type]
        ppublicid  = params[:public_id]
 
        # Step 5.2: Create the Blob object that includes the signed_id
        blob = ActiveStorage::Blob.create_before_direct_upload!(          
          filename: pfilename, 
          byte_size: pbytesize, 
          checksum: pchecksum, 
          content_type: pcontenttype
        )
 
        #Step 5.3: Prepare the information needed in the frontend to perform the updating of the asset public_id in the Media Library using the Blob.key as the filename

        # PLEASE PROTECT THIS SECTION
        cldCloudName = "ecpdemo"
        cldApiKey = "487125246667464"
        cldApiSecretKey = "BpR0LBWVJ3yA7xt9uPggHIECq_k"        
        cldRenameURL = "https://api.cloudinary.com/v1_1/" + cldCloudName + "/image/rename"
        cldBAParams = "Basic " + (Base64.encode64(cldApiKey + ":" + cldApiSecretKey)).tr("\n", '')
        # PLEASE PROTECT THIS SECTION

        unixTimestamp = Time.now.to_i

        cldRenameParams = "from_public_id="
        cldRenameParams.concat(ppublicid)
        cldRenameParams.concat("&timestamp=")
        cldRenameParams.concat(unixTimestamp.to_s)
        cldRenameParams.concat("&to_public_id=")
        cldRenameParams.concat(blob.key)
        cldRenameParams.concat(cldApiSecretKey)
        calcSignature = Digest::SHA1.hexdigest(cldRenameParams)

        # Step 5.4: Return the calculated data back to the frontend to continue the Step 6
        render json: {
          status: 'SUCCESS', 
          message: 'Blob', 
          signed_id: blob.signed_id, 
          blob_key: blob.key,
          cldrenameurl: cldRenameURL,
          baparams: cldBAParams, 
          cldfrompublicid: pfilename,
          cldtopublicid: blob.key,
          cldtimestamp: unixTimestamp,
          cldapikey: cldApiKey,
          cldsignature: calcSignature,
          cldtrenameparams: cldRenameParams,
          blobdata: blob
          }, status: :ok

      end

      # Rescue the Auth Error
      def not_authorized
        render json: { error: 'Not authorized' }, status: :unauthorized
      end


      private

        def uwactivestorage_params
          params.permit(:filename, :byte_size, :checksum, :content_type, :public_id)
        end

        def blob_args
          params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type).to_h.symbolize_keys
        end

        def verified_service_name
          ActiveStorage::DirectUploadToken.verify_direct_upload_token(params[:direct_upload_token], params[:attachment_name], session)
        end

        def direct_upload_json(blob)
          blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
            url: blob.service_url_for_direct_upload,
            headers: blob.service_headers_for_direct_upload
          })
        end



    end
  end
end