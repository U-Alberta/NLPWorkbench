import React from 'react';
import { Typography, Container, List, ListItem, ListItemIcon, ListItemText } from '@mui/material';
import GroupAddIcon from '@mui/icons-material/GroupAddRounded';
import CorporateFareIcon from '@mui/icons-material/CorporateFareRounded';
import HighlightIcon from '@mui/icons-material/HighlightRounded';
import QuizIcon from '@mui/icons-material/Quiz';

export default function AboutField1(props) {
    const exampleJSON = `{
        "doc": [
          {
            "title": "Document 1",
            "author": "John Smith",
            "date": "2022-01-01",
            "text": "This is the first document",
            "content": "This is the first document"
          },
          {
            "title": "Document 2",
            "author": "Jane Doe",
            "date": "2022-01-02",
            "text": "This is the second document",
            "content": "This is the second document"
          }
        ]
      }`;
    return (
        <Container
            sx={{
                m: 1.5,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center'
            }}
        >
            <Typography fontSize='1.5em' fontWeight='bold' variant="h4">About</Typography>
            <Typography m={3}>
                This tool is part of the NLP Workbench. Here users are able to input JSON files in order to be analysed by the NLP Workbench.
                This in turn allows the user to not only limited to single platform like Twitter/Telegram/Search but they can create a custom collection index and upload the JSON files that can be a multi-platform data that they want to be analysed by the NLP Workbench.
                <br /> <br />
                The JSON file scheme we support:
                <br /> <br />
                Required to have at least one JSON field called "doc", and "doc" can contain a single item or multiple items, and each item must have atleast one field called "text" in order to be analyzed by NLP Workbench
                <br /> <br /> 
                Example JSON file:
                <br /> <br /> 
                <code>{exampleJSON}</code>
            </Typography>
            
            {/* <List sx={{width: '100%', mt:-1}}>
                <ListItem>
                    <ListItemIcon>
                        <GroupAddIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="which users and/or tweets have the most interaction/connectivity"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <CorporateFareIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="which persons, organizations, global entities, etc. are mentioned in a given network (entity extraction from tweet embeddings)"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <HighlightIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="how do narratives and emphases shift given certain social networks (gauged by running centrality algorithms)"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <QuizIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="and many other similar questions which are difficult to answer efficiently simply by browsing tweets"
                    />
                </ListItem>
            </List> */}
        </Container>
    );
}