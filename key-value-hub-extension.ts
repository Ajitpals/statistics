// vss-extension.json
{
  "manifestVersion": 1,
  "id": "key-value-hub-extension",
  "publisher": "YOUR_PUBLISHER_NAME",
  "version": "1.0.0",
  "name": "KeyValue Hub",
  "description": "A hub for managing project key-value pairs",
  "public": false,
  "targets": [
    {
      "id": "Microsoft.VisualStudio.Services"
    }
  ],
  "scope": [
    "vso.work"
  ],
  "contributions": [
    {
      "id": "KeyValueHub",
      "type": "ms.vss-web.hub",
      "description": "Adds a KeyValue Hub to the Organization level",
      "targets": [
        "ms.vss-web.collection-admin-hub-section"
      ],
      "properties": {
        "name": "KeyValue Hub",
        "order": 100,
        "uri": "dist/hub.html"
      }
    }
  ],
  "files": [
    {
      "path": "dist",
      "addressable": true
    }
  ]
}

// src/Hub.tsx
import * as React from "react";
import * as ReactDOM from "react-dom";
import * as SDK from "azure-devops-extension-sdk";
import { 
  Button, 
  Card, 
  FormControl, 
  FormLabel, 
  TextField 
} from "@azure/azure-devops-ui/Core";
import { 
  Surface, 
  SurfaceBackground 
} from "@azure/azure-devops-ui/Surface";
import { 
  Table, 
  TableHeader, 
  TableRow, 
  TableCell 
} from "@azure/azure-devops-ui/Table";
import { ExtensionDataService } from "azure-devops-extension-api/ExtensionData";

interface ProjectEntry {
  id: string;
  name: string;
}

const KeyValueHub: React.FC = () => {
  const [projectName, setProjectName] = React.useState("");
  const [projects, setProjects] = React.useState<ProjectEntry[]>([]);

  React.useEffect(() => {
    SDK.init();
    loadProjects();
  }, []);

  const loadProjects = async () => {
    const extensionDataService = await SDK.getService<ExtensionDataService>(
      SDK.ExtensionDataService
    );
    const storedProjects = await extensionDataService.getValue<ProjectEntry[]>(
      "projectEntries",
      { defaultValue: [] }
    );
    setProjects(storedProjects);
  };

  const handleAddProject = async () => {
    if (!projectName.trim()) return;

    const extensionDataService = await SDK.getService<ExtensionDataService>(
      SDK.ExtensionDataService
    );

    const storedProjects = await extensionDataService.getValue<ProjectEntry[]>(
      "projectEntries",
      { defaultValue: [] }
    );

    // Check if project already exists
    const projectExists = storedProjects.some(
      p => p.name.toLowerCase() === projectName.toLowerCase()
    );

    if (projectExists) {
      alert("Project already exists!");
      return;
    }

    const newProject: ProjectEntry = {
      id: Date.now().toString(),
      name: projectName
    };

    const updatedProjects = [...storedProjects, newProject];
    
    await extensionDataService.setValue("projectEntries", updatedProjects);
    setProjects(updatedProjects);
    setProjectName("");
  };

  const handleDeleteProject = async (id: string) => {
    const extensionDataService = await SDK.getService<ExtensionDataService>(
      SDK.ExtensionDataService
    );

    const storedProjects = await extensionDataService.getValue<ProjectEntry[]>(
      "projectEntries",
      { defaultValue: [] }
    );

    const updatedProjects = storedProjects.filter(p => p.id !== id);
    
    await extensionDataService.setValue("projectEntries", updatedProjects);
    setProjects(updatedProjects);
  };

  return (
    <Surface background={SurfaceBackground.default}>
      <div style={{ padding: "20px" }}>
        <Card>
          <div style={{ display: "flex", alignItems: "center", marginBottom: "20px" }}>
            <TextField
              placeholder="Enter Project Name"
              value={projectName}
              onChange={(_, value) => setProjectName(value)}
              style={{ marginRight: "10px", flex: 1 }}
            />
            <Button 
              text="Add Project" 
              onClick={handleAddProject}
              primary
            />
          </div>
        </Card>

        <Card>
          <Table>
            <TableHeader>
              <TableRow>
                <TableCell>Project Name</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHeader>
            {projects.map(project => (
              <TableRow key={project.id}>
                <TableCell>{project.name}</TableCell>
                <TableCell>
                  <Button 
                    text="Delete" 
                    onClick={() => handleDeleteProject(project.id)}
                    danger
                  />
                </TableCell>
              </TableRow>
            ))}
          </Table>
        </Card>
      </div>
    </Surface>
  );
};

ReactDOM.render(<KeyValueHub />, document.getElementById("root"));

// package.json
{
  "name": "key-value-hub-extension",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "dev": "webpack --mode development && tfx extension create"
  },
  "dependencies": {
    "@azure/azure-devops-ui": "^2.0.0",
    "azure-devops-extension-sdk": "^3.0.0",
    "react": "^17.0.2",
    "react-dom": "^17.0.2"
  },
  "devDependencies": {
    "@types/react": "^17.0.0",
    "webpack": "^5.0.0",
    "webpack-cli": "^4.0.0",
    "ts-loader": "^9.0.0",
    "html-webpack-plugin": "^5.0.0"
  }
}

// webpack.config.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/Hub.tsx',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js']
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html'
    })
  ]
}

// src/index.html
<!DOCTYPE html>
<html>
<head>
    <title>KeyValue Hub</title>
</head>
<body>
    <div id="root"></div>
</body>
</html>
