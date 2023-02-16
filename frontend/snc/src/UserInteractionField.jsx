import React, { Component } from 'react';
import { Typography, TextField, Button, ToggleButton, ToggleButtonGroup, Box, Radio, Checkbox, RadioGroup, FormGroup, FormControlLabel, FormControl, FormLabel } from '@mui/material';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import ConstructionIcon from '@mui/icons-material/Construction';
import NorthEastIcon from '@mui/icons-material/NorthEast';
import DeleteIcon from '@mui/icons-material/Delete';

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

class UserInteractionField extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            timeframe: 'week',
            esIndex: null,
            relations: ['embed', 'mention'],
            indexOptions: [],       // Query ES to retrieve indexes on page load
            alignment: {
                value: 'user',
                description: 'twitter handles'
            },
            disableConstruct: true,
            disableDataField: false,
            disableNeo: true,
            constructLoading: false,
            deleteLoading: false
        };
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
                'esindex': this.state.esIndex
            })
        };

        const url = SNC_API_URL + '/run';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
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
    
    _handleDeleteIndexClick = () => {
        // Deletes index from elastic search (specified by this.state.esIndex)
        if(this.state.esIndex === '' || this.state.esIndex === null) {
            return;
        }

        this.setState({
            deleteLoading: true,
            disableConstruct: true
        })

        // Make API request to delete specified index specified by this.state.esIndex
   
        
        // Update available indices at this.state.indexOptions
        let indexOptions_cpy = this.state.indexOptions;
        indexOptions_cpy.splice(indexOptions_cpy.indexOf(this.state.esIndex), 1);

        // Update UI
        this.setState({
            indexOption: indexOptions_cpy,
            esIndex: null,
            deleteLoading: false,
        }, this._updateUIControl)
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
                    flexWrap: 'wrap'
                }}
            >
                <Box 
                    align="left" 
                    sx={{
                        m: 1, 
                        '& .MuiTextField-root': { mt: 3, width: '90%'},
                    }}
                >

                    <Box>
                        <Autocomplete
                            value={this.state.esIndex}
                            onChange={(event, newValue) => {
                                if(newValue && newValue.inputValue) {
                                    // New index specified by user
                                    this.setState({esIndex: newValue.inputValue}, this._updateUIControl)
                                }
                                else {
                                    this.setState({esIndex: newValue}, this._updateUIControl);
                                }
                            }}
                            filterOptions={(options, params) => {
                                const filtered = filter(options, params);
                                const { inputValue } = params;

                                // Suggest new value addition
                                const doesExist = options.some((option) => inputValue === option);
                                if(inputValue !== '' && !doesExist) {
                                    filtered.push({
                                        inputValue,
                                        title: `Create "${inputValue}"`
                                    });
                                }
                                
                                return filtered;
                            }}
                            selectOnFocus
                            clearOnBlur
                            handleHomeEndKeys
                            id='es-index-selection'
                            options={this.state.indexOptions}
                            getOptionLabel={(option) => {
                                if(typeof option === 'string') {
                                    return option;
                                } 
                                else if (option.inputValue) {
                                    // Create "new-index" option 
                                    return option.inputValue;
                                } else {
                                    return option.title;
                                }
                            }}
                            renderOption={(props, option) => {
                                if(option && option.title) {
                                    option = option.title;
                                }
                                return <li {...props}>{option}</li>
                            }}
                            sx={{width: '65%', mb:'0.5em'}}
                            freeSolo
                            renderInput={(params) => (
                                <TextField {...params} label="Select desired collection" />
                            )}
                        />

                        <LoadingButton
                            onClick={this._handleDeleteIndexClick}
                            endIcon={<DeleteIcon />}
                            loading={this.state.deleteLoading}
                            loadingPosition='end'
                            variant='contained'
                            sx={{mb: '2em'}}
                            color='error'
                            size='small'
                        >
                            Delete Index
                        </LoadingButton>
                    </Box>

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


                    <TextDataField 
                        placeholder={this.state.alignment.description} 
                        disabled={this.state.dataDisabled} 
                        onChange={this._handleTextFieldChange} 
                    />

                    <LoadingButton
                        onClick={this._handleConstructClick}
                        endIcon={<ConstructionIcon />}
                        loading={this.state.loading}
                        loadingPosition='end'
                        variant='contained'
                        sx={{mt: '1em'}}
                        disabled={this.state.constructDisabled}
                    >
                        Construct Graph
                    </LoadingButton>

                    <NeoButton disabled={this.state.neoDisabled} onClick={this._handleNeoClick} />
                </Box>
            </Box>
        );
    }
}

export default UserInteractionField;