import { Controller } from "stimulus";
import { DirectUpload } from "@rails/activestorage";
import { FileChecksum } from "@rails/activestorage/src/file_checksum";
import { BlobRecord } from "@rails/activestorage/src/blob_record"

import {
  getMetaValue,
  toArray,
  findElement,
  removeElement,
  insertAfter
  
} from "helpers";

const myCloudName = "ecpdemo";

function launchUploadWidget() {
  cloudinary.openUploadWidget({
    cloudName: myCloudName,
    inlineContainer: '#widgetdiv',
    form: "#uwform",
    uploadPreset: 'testing',
    showPoweredBy: false,
    sources: ['local', 'instagram']
  },
    (error, result) => {
      console.log(result);
      if (!error && result) {

        // Step 1: Upload the asset to the Media Library

        if(result.event === "queues-end")
        {          
          var imageData;

          var myUrl = "https://draganddropactivestorage.ecptest.repl.co/api/v1/uwactivestorage";

          // Step 2: Get the target file information that is in the Media Library (i.e., using the response json)
          console.log(result.info.files[0].uploadInfo)

          var cldTargetUrl = result.info.files[0].uploadInfo.secure_url;
          var dpublicid = result.info.files[0].uploadInfo.public_id
          var dfilename = result.info.files[0].name;
          var dfilesize = result.info.files[0].size;
          var dcontentType = result.info.files[0].type;

          var fetchData =  fetch(cldTargetUrl, { mode: "cors" })
                        .then(res => res.blob())
                        .then(blob => {

                        // Step 3: Get the image from the repository (i.e., Cloudinary)
                        const file = new File([blob], dfilename, { type: dcontentType });

                        // Step 4: Calculate the parameters that is needed for the calculation of Blob.signed_id at the server side of the application
                        FileChecksum.create(file, (error, checksum) => {
                          if (error) {
                            //callback(error)
                            return;
                          }

                          var adata = {
                            filename      :dfilename,
                            byte_size     :dfilesize,
                            checksum      :checksum,
                            content_type  :dcontentType,
                            public_id     :dpublicid 
                          };

                          // Step 5: Delegate to the server side the calculation of the Blob.signed_id together with the parameters to rename the asset in Media Library
                          fetch(myUrl, {
                            method: "POST",
                            headers: {'Content-Type': 'application/json' }, 
                            body: JSON.stringify(adata)
                            })
                          .then(response => response.json())
                          .then(data => {

                            // Step 6. Create/Update the information in the hidden input
                            createHiddenInput(data.signed_id);
                            console.log(data);

                            // Step 7. Rename the asset in the Medial Library to synchronize it with the information stored in the ActiveStorage
                            updateCldMLAsset(data);

                          });
                        });


          });
        }
      } 
    }
  );
}



function updateCldMLAsset(cldData){
        var myHeaders = new Headers();
        myHeaders.append("Authorization", cldData.baparams);
        //myHeaders.append("Cookie", "_cld_session_key=2d37ae513184e3a19477a017f52620d6");

        var formdata = new FormData();
        formdata.append("from_public_id", cldData.cldfrompublicid);
        formdata.append("to_public_id", cldData.cldtopublicid);
        formdata.append("timestamp", cldData.cldtimestamp);
        formdata.append("api_key", cldData.cldapikey);
        formdata.append("signature", cldData.cldsignature);

        var requestOptions = {
            mode: "no-cors",
            method: 'POST',
            headers: myHeaders,
            body: formdata,
            redirect: 'follow'
        };

        fetch(cldData.cldrenameurl, requestOptions)
            .then(response => response.text())
            .then(result => console.log(result))
            .catch(error => console.log('error', error));
}

function createHiddenInput(computedvalue) {
  console.log("Creating the hidden items...");

  const input = document.createElement("input");
  input.type = "hidden";
  input.name = "post[feature_image]";
  input.value = computedvalue;

  const myElement = document.getElementById("uwdiv");
  myElement.style.width = "100px";
  myElement.style.width = "40px";
  myElement.appendChild(input);

  
}

function showHiddenInputs() {
    object = document.getElementsByTagName('input');
    for (var i in object) {
        if (object[i].type === 'hidden') {
            object[i].type = 'text'
        }
    }
}


// Main operations
launchUploadWidget();

showHiddenInputs();