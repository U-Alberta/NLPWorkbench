import React, { Component, useState } from 'react';
import { Select, MenuItem, Typography, TextField, Button, ToggleButton, ToggleButtonGroup, Box, Radio, Checkbox, RadioGroup, FormGroup, FormControlLabel, FormControl, FormLabel, Snackbar, Alert } from '@mui/material';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import ConstructionIcon from '@mui/icons-material/Construction';
import NorthEastIcon from '@mui/icons-material/NorthEast';
import DeleteIcon from '@mui/icons-material/Delete';
import CreateIcon from '@mui/icons-material/Create';
import UpdateIcon from '@mui/icons-material/Update';

const SNC_API_URL = process.env.REACT_APP_SNC_API_URL ? process.env.REACT_APP_SNC_API_URL : "/api/snc";

function TextDataField (props) {
    const placeholder = `Paste your ${props.placeholder} here`;
    return (
        <TextField 
            noValidate 
            autoComplete="off" 
            spellCheck="false" 
            label="Data" 
            onChange={props.onChange} 
            placeholder={placeholder} 
            disabled={props.disabled} 
            multiline
        />
    );
}

function RadioControlLabel (props) {
    return (
        <FormControlLabel 
            label={
                <Typography variant='overline'>{props.label}</Typography>
            }
            value={props.value}
            control={<Radio size='small' />}
        />
    );
}

function NeoButton (props) {
    if (props.disabled) {
        return (
            <Button 
                variant='outlined' 
                endIcon={<NorthEastIcon />} 
                sx={{mt: '1em', ml: '1em'}}
                onClick={props.onClick}
                disabled
            >
                Open in Neo4j
            </Button>
        )
    } 
    return (
        <Button 
            variant='outlined' 
            endIcon={<NorthEastIcon />} 
            sx={{mt: '1em', ml: '1em'}}
            onClick={props.onClick}
        >
            Open in Neo4j
        </Button>
    )
}

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

class TwitterUI extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            timeframe: 'week',
            esIndex: null,
            esIndexDescription: "",
            relations: ['embed', 'mention'],
            indexOptions: [],       // Query ES to retrieve indexes on page load
            alignment: {
                value: 'user',
                description: 'twitter handles'
            },
            disableConstruct: true,
            disableDescription: false,
            disableDataField: false,
            disableNeo: true,
            constructLoading: false,
            deleteLoading: false,
            createLoading: false,
            updateLodaing: false,
            snackbarOpen: false,
            snackbarMessage: '',
            snackbarSeverity: 'success',
            selectedFile: null
        };
    }

    // TODO: Need to update this to accept multiple file uploads
    _handleFileInput = (event) => {
        this.setState({
            selectedFile: event.target.files[0],
        });
    }

    _handleFileSubmit = (event) => {
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
                });
              })
            } else {
              response.json().then(data => {
                console.log(data);
                this.setState({
                  snackbarOpen: true,
                  snackbarMessage: data,
                  snackbarSeverity: 'success',
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

    _handleToggleButtonChange = (event, newAlignment) => {
        let desc;
        if(newAlignment === 'user') {
            desc = 'twitter handles';
        } else if (newAlignment === 'tweet') {
            desc = 'tweet IDs';
        } else {
            desc = 'hashtags';
        }
        this.setState({alignment: {
            value: newAlignment,
            description: desc
        }});
    }

    _handleTextFieldChange = (event) => {
        this.setState({
            userInput: event.target.value, 
        }, this._updateUIControl);
    }

    _handleRadioChange = (event) => {
        this.setState({timeframe: event.target.value});
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

    _handleNeoClick = () => {
        // Will redirect to neo4j browser (placeholder below for the time being)
        window.open('https://neo4j.com/docs/operations-manual/5/installation/neo4j-browser/', '_blank')
    }

        
    _handleCreateIndexClick = () => {
        // Create index from elastic search (specified by this.state.esIndex)
        //  || this.state.indexOptions.indexOf(this.state.esIndex) === -1
        if(this.state.esIndex === '' || this.state.esIndex === null || this.state.indexOptions.indexOf(this.state.esIndex) !== -1) {
            if (this.state.indexOptions.indexOf(this.state.esIndex) !== -1){
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Index already exist',
                    snackbarSeverity: 'error',
                });
            }
            else{
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Index name is required to create a index',
                    snackbarSeverity: 'warning',
                });
            }
            return;
        }

        this.setState({
            createLoading: true
        })

        // Make API request to create specified index specified by this.state.esIndex
        const requestOptions = {
            method: 'PUT',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'index_name': this.state.esIndex,
                'description': this.state.esIndexDescription
            })
        };

        const url = SNC_API_URL + '/indexes/create';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'error',
                        });
                    });
                }
                else{
                    // console.log(response.json());
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'success',
                        });
                    });
                    let indexOptions_cpy = this.state.indexOptions;
                    indexOptions_cpy.push(this.state.esIndex);
                    this.setState({
                        indexOptions: indexOptions_cpy
                    });
                }
            })
            .then(() => {
                        this.setState({
                            createLoading: false
                        })})
        
    }

    
    _handleDeleteIndexClick = () => {
        // Deletes index from elastic search (specified by this.state.esIndex)
        if(this.state.esIndex === '' || this.state.esIndex === null) {
            this.setState({
                snackbarOpen: true,
                snackbarMessage: 'Index name is required to delete a index',
                snackbarSeverity: 'error',
            });
            return;
        }

        if(this.state.indexOptions.indexOf(this.state.esIndex) === -1){
            this.setState({
                snackbarOpen: true,
                snackbarMessage: "Index doesn't exist in collection",
                snackbarSeverity: 'error',
            });
            return;
        }

        this.setState({
            deleteLoading: true
        })

        // Make API request to delete specified index specified by this.state.esIndex
        const requestOptions = {
            method: 'DELETE',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'index_name': this.state.esIndex
            })
        };

        const url = SNC_API_URL + '/indexes/delete';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'error',
                        });
                    })                    
                }
                else{
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'success',
                        });
                        let indexOptions_cpy = this.state.indexOptions;
                        indexOptions_cpy.splice(indexOptions_cpy.indexOf(this.state.esIndex), 1);
                        this.setState({
                            indexOptions: indexOptions_cpy,
                            esIndex: null,
                            esIndexDescription: ""
                        })
                    })
                }
            })            
            .then(() => {
                this.setState({
                    deleteLoading: false
                })})

    }

    _handleRelationChange = (event) => {
        let relations_cpy = this.state.relations;
        if(event.target.checked && !relations_cpy.includes(event.target.value)) {
            relations_cpy.push(event.target.value);                                         // Add to relations if checked
        }
        else if (!event.target.checked && relations_cpy.includes(event.target.value)) {
            relations_cpy.splice(relations_cpy.indexOf(event.target.value), 1);             // Remove from relations if unchecked
        }

        this.setState({relations: relations_cpy}, this._updateUIControl);        
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
                        <ToggleButtonGroup 
                            color='primary'
                            value={this.state.alignment.value} 
                            aria-label='data type' 
                            onChange={this._handleToggleButtonChange}
                            exclusive
                        >
                            <ToggleButton value='user'>Users</ToggleButton>
                            <ToggleButton value='tweet'>Tweets</ToggleButton>
                            <ToggleButton value='hashtag'>Hashtag</ToggleButton>
                        </ToggleButtonGroup>

                        <FormControl size='small' sx={{ml: 6}}>
                            <FormLabel id='row-radio-time-frame' sx={{fontSize: '0.8em'}}>TIME FRAME</FormLabel>
                            <RadioGroup
                                row
                                name='row-radio-time-frame-buttons'
                                value={this.state.timeframe}
                                onChange={this._handleRadioChange}
                            >
                                <RadioControlLabel value='week' label='Week' />
                                <RadioControlLabel value='month' label='Month' />
                                <RadioControlLabel value='3month' label='3 Months' />
                                <RadioControlLabel value='other' label='Other' />
                            </RadioGroup>
                        </FormControl>
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

                        <FormControl
                            fullWidth={true}
                        >
                            <FormLabel id='row-checkbox-relations' sx={{mt: '1em', fontSize: '0.8em'}}>RELATIONS</FormLabel>
                            <FormGroup row={true}>
                                <FormControlLabel control={<Checkbox value='like' onChange={this._handleRelationChange} />} label='Likers' />
                                <FormControlLabel control={<Checkbox value='follow' onChange={this._handleRelationChange} />} label='Followers' />
                                <FormControlLabel control={<Checkbox value='retweet' onChange={this._handleRelationChange} />} label='Retweeters' />
                                <FormControlLabel control={<Checkbox value='embed' onChange={this._handleRelationChange} defaultChecked />} label='Embedded entities' />
                                <FormControlLabel control={<Checkbox value='mention' onChange={this._handleRelationChange} defaultChecked />} label='Mentioned users' />
                            </FormGroup>
                        </FormControl>
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
                        <TextDataField 
                            placeholder={this.state.alignment.description} 
                            disabled={this.state.dataDisabled} 
                            onChange={this._handleTextFieldChange} 
                        />
                    </Box>

                    <LoadingButton
                        onClick={this._handleUpdateCollectionClick}
                        endIcon={<UpdateIcon />}
                        loading={this.state.updateLodaing}
                        loadingPosition='end'
                        variant='contained'
                        sx={{ml: 2, mt: 2}}
                        disabled={this.state.updateLodaing}
                    >
                        Update Collection
                    </LoadingButton>


                    <LoadingButton
                        onClick={this._handleConstructClick}
                        endIcon={<ConstructionIcon />}
                        // loading={this.state.loading}
                        loading={this.state.constructLoading}
                        loadingPosition='end'
                        variant='contained'
                        sx={{mt: 2, ml: 2}}
                        disabled={this.state.constructDisabled}
                    >
                        Construct Graph
                    </LoadingButton>

                    <NeoButton disabled={this.state.neoDisabled} onClick={this._handleNeoClick} />

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

export default TwitterUI;