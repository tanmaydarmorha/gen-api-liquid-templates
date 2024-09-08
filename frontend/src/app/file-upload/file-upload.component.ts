import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, timeout } from 'rxjs';

@Component({
  selector: 'app-file-upload',
  templateUrl: './file-upload.component.html',
  styleUrls: ['./file-upload.component.css']
})
export class FileUploadComponent implements OnInit {
  selectedFiles: { [key: string]: File | null } = {
    inputJson: null,
    sampleOutput: null,
    mappingDocument: null
  };
  isLoading = false;
  isLoadingTimeout: any; 
  responseMessage: string | null = null;

  constructor(private http: HttpClient) { }

  ngOnInit(): void { }

  onFileSelected(fileType: string, event: any) {
    this.selectedFiles[fileType] = event.target.files[0];
  }

  processFiles(): void {
    this.isLoading = true;
    this.responseMessage = null;

    const formData = new FormData();

    // Append files to FormData with corresponding keys
    if (this.selectedFiles['inputJson']) {
      formData.append('inputJson', this.selectedFiles['inputJson']);
    }
    if (this.selectedFiles['sampleOutput']) {
      formData.append('sampleOutput', this.selectedFiles['sampleOutput']);
    }
    if (this.selectedFiles['mappingDocument']) {
      formData.append('mappingDocument', this.selectedFiles['mappingDocument']);
    }

    // Set a timeout for the loading indicator (e.g., 5 seconds)
    this.isLoadingTimeout = setTimeout(() => {
      this.isLoading = false; 
    }, 5000);
    this.http
      .post('http://localhost:8080/processFiles', formData)
      .pipe(timeout(10000))
      .subscribe(
        (response: any) => {
          this.responseMessage = response.message;
          clearTimeout(this.isLoadingTimeout);
        },
        (error) => {
          console.error('Error processing files:', error);
          this.responseMessage = 'Error occurred during processing.';
          clearTimeout(this.isLoadingTimeout);
        }
      )
      .add(() => {
        this.isLoading = false;
        clearTimeout(this.isLoadingTimeout);
      });
  }
}