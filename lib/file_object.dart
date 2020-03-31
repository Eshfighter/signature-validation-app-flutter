import 'dart:io';

class FileObject{
  File image;
  String fileSelected;

  FileObject(this.image,this.fileSelected);

  void setFile(_image,_fileSelected){
    image = _image;
    fileSelected = _fileSelected;
  }

  File getImage(){
    return image;
  }

  String getFileSelected(){
    return fileSelected;
  }

  void clear(){
    image = null;
    fileSelected = null;
  }
}