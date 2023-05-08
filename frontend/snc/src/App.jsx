import React, {useState} from 'react';
import {Divider, Typography, AppBar, CssBaseline,Toolbar, Container, IconButton, Box, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText } from '@mui/material';
import HomeIcon from '@mui/icons-material/Home';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';

import TwitterUI from './TwitterUI';
// import AboutField from './AboutField';
import LocalFileUI from './LocalFileUI';
// import AboutField1 from './AboutField1';
import CreateCollectionTab from './CreateCollectionTab';
import DeleteCollectionTab from './DeleteCollectionTab';
import ReadCollectionTab from './ReadCollectionTab';
import ExportMetaTab from './ExportMetaTab';
import BatchExecutionTab from './BatchExecutionTab';
import VisualizeCollectionTab from './VisualizeCollectionTab';
import CreateNetworkTab from './CreateNetworkTab';
import UpdateNetworkTab from './UpdateNetworkTab';
import DeleteNetworkTab from './DeleteNetworkTab';
import VisualizeNetworkTab from './VisualizeNetworkTab';

function NavBar(props) {
    return (
        <AppBar position="relative">
            <Toolbar>
                <IconButton aria-label={props.label} href={props.url} target="_blank">
                    <HomeIcon />
                </IconButton>
                <Typography ml={3} variant="h5" sx={{fontWeight: 'bold'}}>
                    {props.title}
                </Typography>
            </Toolbar>
        </AppBar>
    );
}

// function Header(props) {
//     return (
//         <Container maxWidth="sm">
//             <Typography variant="h2" align="center" color="textPrimary" gutterBottom sx={{whiteSpace: 'nowrap', fontSize: '2em'}}>
//                 Social Network Constructor
//             </Typography>
//             <Typography variant="h5" align="center" color="textSecondary" paragraph sx={{fontSize: '0.75em'}}>
//                 A tool for constructing social networks consisting of twitter users, tweets, organizations, persons, and many other entities. Simply provide either the base usernames or tweets and run this tool to visualize the data.
//             </Typography>
//         </Container>
//     )
// }

function App() {
    const create_collection = "CREATE COLLECTION";
    const delete_collection = "DELETE COLLECTION";
    const read_collection_log = "READ COLLECTION LOG";
    const import_documents = "IMPORT DOCUMENTS";
    const export_metadata = "EXPORT METADATA";
    const batch_execution = "BATCH EXECUTION";
    const visualize_collection = "VISUALISE COLLECTION";
    const create_network = "CREATE NETWORK";
    const update_network = "UPDATE NETWORK";
    const delete_network = "DELETE NETWORK";
    const visualize_network = "VISUALISE NETWORK";

    const [selectedOption, setSelectedOption] = useState('Twitter');
    const [selectedCollectionOption, setSelectedCollectionOption] = useState(create_collection);
    const [drawerOpen, setDrawerOpen] = useState(true);
    
    const handleOptionChange = (event, newOption) => {
        setSelectedOption(newOption);
    };

    const handleCollectionOptionChange = (event, newOption) => {
        setSelectedCollectionOption(newOption);
    };    

    const renderUserInteractionField = () => {    
        if (selectedCollectionOption !== import_documents){
            if (selectedCollectionOption === create_collection){
                return <CreateCollectionTab />;
                // return <CollectionManagementTab selectedCollectionOption={create_collection} />;
            }
            if (selectedCollectionOption === delete_collection){
                return <DeleteCollectionTab />;
                // return <CollectionManagementTab selectedCollectionOption={delete_collection} />;
            }
            if (selectedCollectionOption === read_collection_log){
                return <ReadCollectionTab />;
                // return <CollectionManagementTab selectedCollectionOption={read_collection_log} />;
            }
            if (selectedCollectionOption === export_metadata){
                return <ExportMetaTab />;
            }
            if (selectedCollectionOption === batch_execution){
                return <BatchExecutionTab />;
            }
            if (selectedCollectionOption === visualize_collection){
                return <VisualizeCollectionTab />;
            }
            if (selectedCollectionOption === create_network){
                return <CreateNetworkTab />;
            }
            if (selectedCollectionOption === update_network){
                return <UpdateNetworkTab />;
            }
            if (selectedCollectionOption === delete_network){
                return <DeleteNetworkTab />;
            }
            if (selectedCollectionOption === visualize_network){
                return <VisualizeNetworkTab />;
            }
        }
        else{
            if (selectedCollectionOption === import_documents && selectedOption === "Twitter"){
                return <TwitterUI />;
            }
            if (selectedCollectionOption === import_documents && selectedOption === "LocalFile"){
                return <LocalFileUI />;
            }
            // else{
            //     // TODO: Need update this
            //     return <CollectionManagementTab selectedCollectionOption={create_collection} />;
            // }
        }
    };

    // const renderAboutField = () => {
    //     if (selectedOption === 'Twitter') {
    //         return <AboutField />;
    //     } else {
    //         return <AboutField1 />;
    //     }
    // };

    return (
        <React.Fragment>
            <Box sx={{display:"flex"}}>
                <CssBaseline />
                <Drawer 
                    anchor="left" 
                    open={drawerOpen} 
                    variant="permanent" 
                    sx={{ 
                        width: "240px",
                        flexShrink: 0,
                        '& .MuiDrawer-paper':{
                            width: 240,
                            boxSizing: 'border-box'
                        }
                        }}>
                                                
                    <List sx={{ alignItems: 'center', mt: 5, flexWrap: 'wrap'}}>
                        <ListItem>
                            <ListItemText
                                primary="Collection Management"
                                primaryTypographyProps={{ fontWeight: "bold", flexWrap: 'wrap' }}
                            />
                        </ListItem>
                        <ListItemButton onClick={() => setSelectedCollectionOption(create_collection)} selected={selectedCollectionOption === create_collection}>
                            <ListItemText primary={create_collection} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(delete_collection)} selected={selectedCollectionOption === delete_collection}>
                            <ListItemText primary={delete_collection} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(read_collection_log)} selected={selectedCollectionOption === read_collection_log}>
                            <ListItemText primary={read_collection_log} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(import_documents)} selected={selectedCollectionOption === import_documents}>
                            <ListItemText primary={import_documents} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(export_metadata)} selected={selectedCollectionOption === export_metadata}>
                            <ListItemText primary={export_metadata} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(batch_execution)} selected={selectedCollectionOption === batch_execution}>
                            <ListItemText primary={batch_execution} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(visualize_collection)} selected={selectedCollectionOption === visualize_collection}>
                            <ListItemText primary={visualize_collection} />
                        </ListItemButton>
                        <ListItem>
                            <ListItemText
                                primary="Network (Neo4j)"
                                primaryTypographyProps={{ fontWeight: "bold", flexWrap: 'wrap' }}
                            />
                        </ListItem>
                        <ListItemButton onClick={() => setSelectedCollectionOption(create_network)} selected={selectedCollectionOption === create_network}>
                            <ListItemText primary={create_network} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(update_network)} selected={selectedCollectionOption === update_network}>
                            <ListItemText primary={update_network} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(delete_network)} selected={selectedCollectionOption === delete_network}>
                            <ListItemText primary={delete_network} />
                        </ListItemButton>
                        <ListItemButton onClick={() => setSelectedCollectionOption(visualize_network)} selected={selectedCollectionOption === visualize_network}>
                            <ListItemText primary={visualize_network} />
                        </ListItemButton>
                    </List>
                </Drawer>

                <Box sx={{ flexGrow: 1 }}>

                    <NavBar url="/" title="Workbench SNC" label="workbench home"/>

                    {selectedCollectionOption === import_documents ? (
                        <Box align="left" sx={{ display: 'flex', flexDirection: 'column', my: 2, ml: 2, width: '60%'}}>
                        <Box>
                            <ToggleButtonGroup sx={{mt: 4, ml: 6}} value={selectedOption} exclusive onChange={handleOptionChange}>
                            <ToggleButton value="Twitter">Twitter</ToggleButton>
                            <ToggleButton value="LocalFile">LocalFile</ToggleButton>
                            </ToggleButtonGroup>
                        </Box>
                        <Box>
                        {/* <Box align="left" sx={{ width: '60%', ml: 2 }}> */}
                            {renderUserInteractionField()}
                        </Box>
                        </Box>
                    ) : (
                        <Box align="left" sx={{ width: '60%', my: 2, ml: 2 }}>
                        {renderUserInteractionField()}
                        </Box>
                    )}
                </Box>
            </Box>
        </React.Fragment>
    );
}

export default App;