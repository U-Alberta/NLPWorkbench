import React, { Component} from 'react';
import { Select, MenuItem, Button, Box, Snackbar, Alert} from '@mui/material';
import { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import PublishIcon from '@mui/icons-material/Publish';

const SNC_API_URL = process.env.REACT_APP_SNC_API_URL ? process.env.REACT_APP_SNC_API_URL : "/api/snc";

function fetchEsIndexes () {
    /*
    Makes a request to the back-end API to fetch existent ElasticSearch network indexes.
    */
    const url = SNC_API_URL + '/indexes';
    return new Promise((resolve, reject) => {
        fetch(url)
            .then((response) => response.json())
            .then((es_indexes) => {
                console.log(es_indexes);
                resolve(es_indexes);
            })
            .catch((err) => {
                console.log('Error: could not fetch ElasticSearch indexes');
                reject(err);
            })
    })
}

class LocalFileUI extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            timeframe: 'week',
            esIndex: null,
            esIndexDescription: "",
            indexOptions: [],       // Query ES to retrieve indexes on page load
            disableConstruct: true,
            disableDescription: false,
            disableNeo: true,
            updateLodaing: false,
            uploadLoading: false,
            submitLoading: false,
            snackbarOpen: false,
            showLogDialog: false,
            snackbarMessage: '',
            snackbarSeverity: 'success',
            selectedFile: null,
            logList: []
        };
    }

    // TODO: Need to update this to accept multiple file uploads
    _handleFileInput = (event) => {
        this.setState({
            selectedFile: event.target.files[0],
            uploadLoading: true
        });
    }

    _handleFileSubmit = (event) => {
        if(this.state.esIndex === null || this.state.selectedFile === null) {
            if (this.state.esIndex === null){
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Index name is required to submit the file',
                    snackbarSeverity: 'error',
                });
            }
            else{
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Please upload is file to submit',
                    snackbarSeverity: 'warning',
                });
            }
            return;
        }

        
        this.setState({
            submitLoading: true
        })

        event.preventDefault();
      
        const formData = new FormData();
        formData.append('file', this.state.selectedFile);
        formData.append('esindex', this.state.esIndex);
        formData.append('description', this.state.esIndexDescription);
      
        const requestOptions = {
          method: 'POST',
          body: formData,
        };
      
        const url = SNC_API_URL + '/uploadfile';
        fetch(url, requestOptions)
          .then((response) => {
            if (response.status !== 200 || !response.ok) {
              // error
              this._handleApiError();
              response.json().then(data => {
                console.log(data);
                this.setState({
                  snackbarOpen: true,
                  snackbarMessage: data,
                  snackbarSeverity: 'error',
                  uploadLoading: false,
                  submitLoading: false
                });
              })
            } else {
              response.json().then(data => {
                console.log(data);
                this.setState({
                  snackbarOpen: true,
                  snackbarMessage: data,
                  snackbarSeverity: 'success',
                  uploadLoading: false,
                  submitLoading: false,
                  selectedFile: null
                });
              });
            }
        });
    }    
      
    _updateUIControl = () => {
        // If all input is valid but construct btn disabled, enable it - otherwise disable it
        if(this.state.relations.length > 0 && this.state.userInput.length > 2 && this.state.esIndex != null) {
            this.setState({
                disableConstruct: false
            });
        } else {
            this.setState({
                disableConstruct: true
            });
        }
    }

    _handleTextFieldChange = (event) => {
        this.setState({
            userInput: event.target.value, 
        }, this._updateUIControl);
    }

    _handleApiError = () => {
        console.log("API ERROR!");
    }

    _handleDescription = (event) => {
        this.setState({esIndexDescription: event.target.value}, this._updateUIControl);
    }


    _handleUpdateCollectionClick = () => {
        this.setState({
            updateLodaing: true,
            disableNeo: true,
            disableDataField: true
        })
        
        // Call API and queue SNC task
        const requestOptions = {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'identifiers': this.state.userInput.split('\n'),
                'type': this.state.alignment.value,
                'time': this.state.timeframe,
                'relations': this.state.relations,
                'esindex': this.state.esIndex,
                'description': this.state.esIndexDescription
            })
        };

        const url = SNC_API_URL + '/run';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                }                
                else{
                    this.setState({
                        snackbarOpen: true,
                        snackbarMessage: 'Update Collection Successful!',
                        snackbarSeverity: 'success',
                    });
                }
            })
            .then(() => this.setState({
                updateLodaing: false, 
                disableDataField: false,
                disableNeo: false
            }))
    }

    _handleConstructClick = () => {
        this.setState({
            constructLoading: true,
            disableNeo: true,
            disableDataField: true
        })
        
        // Call API and queue SNC task
        const requestOptions = {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'identifiers': this.state.userInput.split('\n'),
                'type': this.state.alignment.value,
                'time': this.state.timeframe,
                'relations': this.state.relations,
                'esindex': this.state.esIndex,
                'description': this.state.esIndexDescription
            })
        };

        const url = SNC_API_URL + '/run';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                }
                else{
                    this.setState({
                        snackbarOpen: true,
                        snackbarMessage: 'Graph build successful!',
                        snackbarSeverity: 'success',
                    });
                }
            })
            .then(() => this.setState({
                constructLoading: false, 
                disableDataField: false,
                disableNeo: false
            }))
    }
            
    componentDidMount() {
        fetchEsIndexes()
            .then((es_indexes) => {
                this.setState({
                        indexOptions: es_indexes
                    });
            })
            .catch((err) => {
                console.log(err);
            })
    }

    render() { 
        const filter = createFilterOptions();
        return (
            <Box
                sx={{
                    display: 'flex',
                    flexWrap: 'wrap',
                    my: 2,
                    ml: 2,
                }}
            >
                <Box 
                    align="left" 
                    sx={{
                        // m: 1,
                        my: 2,
                        ml: 2, 
                        '& .MuiTextField-root': { mt: 3, width: '90%'},
                    }}
                >

                    <Box
                        sx={{
                            display: 'flex',
                            flexWrap: 'wrap',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            width: '100%',
                            my: 2,
                            ml: 2,
                        }}                    
                    >
                        <Select
                                value={this.state.esIndex}
                                onChange={(event) => {
                                    const newValue = event.target.value;
                                    this.setState({esIndex: newValue, deletedisable: false, createdisable: true});
                                }}
                                id='es-index-selection'
                                sx={{width: '60%'}}
                                disabled={this.state.indexOptions.length === 0}
                                displayEmpty
                                renderValue={(value) => value || 'Select Desired Collection'}
                            >
                                <MenuItem value="" disabled>Select Desired Collection</MenuItem>
                                {this.state.indexOptions.map((option) => (
                                    <MenuItem key={option} value={option}>{option}</MenuItem>
                                ))}
                            </Select>
                    </Box>

                    <Box
                        sx={{
                            display: 'flex',
                            flexWrap: 'wrap',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            width: '100%',
                            my: 2,
                            ml: 2,
                        }}                    
                    >
                        <div
                            style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'center', height: '200px', width: '600px', border: '2px dashed grey' }}
                            onDragOver={(e) => {
                                e.preventDefault();
                            }}
                            onDragEnter={(e) => {
                                e.preventDefault();
                                e.currentTarget.style.border = '2px dashed black';
                            }}
                            onDragLeave={(e) => {
                                e.preventDefault();
                                e.currentTarget.style.border = '2px dashed grey';
                            }}
                            onDrop={(e) => {
                                e.preventDefault();
                                e.currentTarget.style.border = '2px dashed grey';
                                const file = e.dataTransfer.files[0];
                                this.setState({
                                    selectedFile: file,
                                    uploadLoading: false
                                });
                            }}
                        >
                            {this.state.selectedFile ? (
                                <Box sx={{ textAlign: 'center' }}>
                                    <p>Selected file: {this.state.selectedFile.name}</p>
                                    <p>File size: {this.state.selectedFile.size} bytes</p>
                                </Box>
                            ) : (
                                <Box sx={{ textAlign: 'center' }}>
                                    <p>Drag and drop a JSON file here, or click to select a file.</p>
                                    <p>Maximum file size: 10 MB.</p>
                                    <Button variant="contained" component="label" size='small'>
                                        Select File
                                        <input
                                            type="file"
                                            accept=".json"
                                            onChange={(event) => {
                                                this.setState({
                                                    selectedFile: event.target.files[0],
                                                    uploadLoading: true
                                                });
                                            }}
                                            hidden
                                        />
                                    </Button>
                                </Box>
                            )}
                        </div>
                    </Box>

                    <LoadingButton 
                        variant="contained" 
                        color="primary" 
                        endIcon={<PublishIcon />}
                        loading={this.state.submitLoading}
                        loadingPosition='end'
                        onClick={this._handleFileSubmit} 
                        sx={{ml: 2, mt: 2}}
                        disabled={!this.state.selectedFile}
                    >
                        Upload File
                    </LoadingButton>

                    <Snackbar
                        open={this.state.snackbarOpen}
                        autoHideDuration={3000}
                        onClose={() => this.setState({ snackbarOpen: false })}
                    >
                        <Alert
                            onClose={() => this.setState({ snackbarOpen: false })}
                            severity={this.state.snackbarSeverity}
                            sx={{ width: '100%' }}
                        >
                            {this.state.snackbarMessage}
                        </Alert>
                    </Snackbar>
                </Box>
            </Box>
        );
    }
}

export default LocalFileUI;