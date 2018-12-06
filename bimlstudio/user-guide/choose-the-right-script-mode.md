# Choose the Right BimlScript Type

BimlScript is useful in a variety of situations, including those that require automation (such as repetitive tasks) or where the declarative Biml model isn't sufficient; e.g. conditionally creating a column in a table.

Before you write a BimlScript, however, you'll first want to decide which BimlScript type is appropriate for your task.

There are three BimlScript types to choose from:

1. Executable
2. Live
3. Transformers

This article explains each type, enabling you to choose the right type for your needs.

## Executable

**Trigger:**
On Demand:

**Description:**
Executable BimlScript is BimlScript that is applied to a Mist project on-demand. Executable BimlScripts are created by adding BimlScript assets to a Mist project; these assets are listed in the logical view's BimlScript Library group. An executable BimlScript can be authored in Mist's BimlScript editor; the BimlScript's results can be previewed within the editor too. When the BimlScript is error free, you can press the ribbon's Expand button to compile and execute the BimlScript. This results in any assets, created by the executable BimlScript, being immediately added to your Mist project.

**Example Creating New Objects:**
Our [Importing Tables With BimlScript](http://www.varigence.com/documentation/mist/018_ImportingTablesWithBimlScript.htm) example demonstrates executable BimlScript. Each time you press the Expand button, the BimlScript is compiled and any .NET code is executed. All assets generated by the code are then added to your project. From there, you can alter them however you wish, as if you had manually created each one.
![Late Arriving Dimension in BimlScript editor](https://varigencecom.blob.core.windows.net/images-mistdocumentation/230_LADBimlScriptEditor.png)

To demonstrate this, consider a project that has an ETL package with a couple of Lookup components. We want to update each Lookup to handle Late Arriving Dimension logic. To accomplish this, we need a way to define the Lookups in Packages that already exist.

An executable BimlScript, that inserts Late Arriving Dimension logic, might look like this:

```biml
<#@ template language="C#" hostspecific="True" mergemode="LocalReplace"#>
<#@ target type="Lookup" #>

<# if (TargetNode.Annotations["LateArriving"] != null) { #>
<Transformations>
    <#=TargetNode.EmitAllXml()#>
    <DerivedColumns Name="_<#=TargetNode.Name#>_DerivedColumnsDefaultValue">
        <InputPath OutputPathName="<#=TargetNode.Name#>.NoMatch" />
        <Columns>
            <Column Name="<#=TargetNode.Annotations["LateArriving"].Text#>" DataType="Int32">0</Column>
        </Columns>
    </DerivedColumns>
    <OleDbCommand Name="_<#=TargetNode.Name#>_OleDBCommandInsertPlaceholderRow" ConnectionName="DataWarehouse"
        ValidateExternalMetadata="False">
        <DirectInput>EXEC pInsertCustomer ?, ? OUTPUT</DirectInput>
        <Parameters>
            <Parameter SourceColumn="Customer" TargetColumn="@CustomerName" />
            <Parameter SourceColumn="SalesAmount" TargetColumn="@CustomerID" />
        </Parameters>
    </OleDbCommand>
    <UnionAll Name="_<#=TargetNode.Name#>_UnionAllMatchAndNoMatch">
        <InputPaths>
            <InputPath OutputPathName="<#=TargetNode.Name#>.Match" />
            <InputPath OutputPathName="_<#=TargetNode.Name#>_OleDBCommandInsertPlaceholderRow.Output" />
        </InputPaths>
    </UnionAll>
</Transformations>
<# } #>
```

The first thing to notice is that the Biml portion doesn't start with a Biml tag; it begins with a Transformations tag instead. This BimlScript fragment, that doesn't begin with a Biml tag, is called a *partial* BimlScript. Partial BimlScripts are used to merge changes into existing Biml assets. Only Executable and Transformer BimlScripts support partial BimlScript.

This partial BimlScript generates a Biml fragment that will be inserted into existing nodes. The type of node that will be edited is of type Lookup, which is set in the target type directive at the top of the script. When this partial BimlScript is executed via the ribbon's Expand button, it will be applied to all Lookup nodes in the project, inserting the Transformations collection that's specified in the script.

By specifying a target type, BimlScripts gain access to a built-in TargetNode property. When a BimlScript is executed, it's run on each node in the project whose type matches the target type. The TargetNode property contains the node that the BimlScript is being run on. This enables a BimlScript author to set conditionals based on the properties on a node; in the above example, there's an if statement that checks if the TargetNode's Annotations collection holds an annotation named 'LateArriving'. This capability enables fine grained control of the specific nodes that will be modified by a BimlScript.

## Live

**Trigger:**
Project Changes

**Description:**
Live BimlScript is BimlScript that's placed within a regular Biml file. This causes the BimlScript-generated objects to become 'live' objects. They are compiled and executed whenever there are changes to the project. Thus, assets generated by live BimlScript are always up-to-date. Because they are re-generated by any change, however, they can't be altered within Mist visual designers; changes must be made to the live BimlScript itself, using the Biml editor.

**Example Creating New Objects**
One common use of live BimlScript is automatically generating Biml code within a Biml file. For instance, the [Federal Reserver sample](http://www.varigence.com/samples/mist/federal-reserve#buildDataPackage) demonstrates live BimlScript in the LoadDimDate package. Within this package is an ExecuteSQL task that needs to insert all dates, from January 1<sup>st</sup> 1900 to December 31<sup>st</sup> 1979, into a Date dimension. Rather than generating the dates in another tool and copy/pasting them into the editor, live BimlScript is used. A simple for loop iterates over the range of dates, adding an INSERT INTO statement for each. This is particularly powerful if you ever need to change the date range; a one line change to enter the new date causes the live BimlScript to immediately re-run, generating the updated dates in the SQL query.

Of course, live BimlScript can also be used to generate Biml assets.

```biml
<#@ template language="C#" hostspecific='true'#>
<#@ import namespace="System.Data" #>

<Biml xmlns="http://schemas.varigence.com/biml.xsd">
    <Connections>
        <OleDbConnection Name='Source' ConnectionString='Provider=SQLNCLI10;Server=.;
            Initial Catalog=AdventureWorksDW2008R2;Integrated Security=SSPI;'/>
    </Connections>
    <Packages>
        <Package Name='Rebuild Warehouse Data' ConstraintMode='Linear' AutoCreateConfigurationsType="None">
            <Tasks>
                <# foreach (var table in RootNode.Tables) 
                { 
                    if (!table.Schema.Name == 'dbo')
                    {
                    #>
                        <Dataflow Name="Copy Data" <#=table.Name#>>
                            <Transformations>
                                <OleDbSource Name="Retrieve Data" ConnectionName="Source">
                                    <DirectInput>SELECT * FROM <#=table.Name#></DirectInput>
                                </OleDbSource>
                                <OleDbDestination Name="Insert Data" ConnectionName="Target">
                                <ExternalTableOutput Table="<#=table.Name#>"/>
                                <OleDbDestination>
                            </Transformations>
                    </Dataflow>
                    <# }
                } #>
            </Tasks>
        </Package>
    </Packages>
</Biml>
```

In this example, a new Dataflow task is created for each table in a project that is not in the dbo schema. Each Dataflow task retrieves a table's data from a Source connection and copies that data to a Target connection. This illustrates that BimlScript can take advantage of conditionals like any .NET code.

![Rebuild Warehouse Data package](https://varigencecomstaging.blob.core.windows.net/images-mistdocumentation/230_RebuildWarehouseDataPackage.png)

If the above sample had been applied as executable BimlScript, and new tables were added in the project, Dataflow tasks for those tables wouldn't be automatically added to the package. This illustrates the key difference between executable vs. live BimlScript: one-time generation of editable assets vs. always up-to-date and un-editable assets.

### Transformers

**Trigger:**

Build

**Description**
The final type of BimlScript is a transformer. Transformers are BimlScripts whose changes are only applied when building a project, instead of the changes being applied within Mist.

**Example:**
One scenario where transformers are useful is when an architect wants to apply a specific pattern to Biml assets used within a project, or even across multiple projects. For instance, perhaps there's a logging pattern that should be applied to all packages. The architect can author the pattern in a transformer within Mist, letting him leverage intelliprompt and the BimlScript editor's preview pane. However, instead of executing it in Mist (which would only apply it to the current set of packages), he can add a command line option to the project to execute the transformer's Biml file during a build:

--transformationScriptSettings &lt;path to ScriptSettings
file&gt; *the ScriptSettings file contains a path to the BimlScript file*

When another developer builds the project, the logging pattern is applied to all of his project's packages automatically. Even better, if the pattern needs to be updated in the future, the architect can make the appropriate change and any developer can apply it just by rebuilding his project.

Transformers allow architects to worry about enforcing patterns and best practices, while other developers focus on the business logic. Additionally, transformers make it easy to change patterns over time by not altering the Biml files on disk.

#### Conclusion

As discussed, the three types of BimlScript enable a wide range of development scenarios. Additionally, partial BimlScripts empower you to merge changes into existing Biml assets.

This chart summarizes the three types of BimlScript and their key differences. Refer to it as you begin leveraging BimlScript so you can choose the right type for your scenario.

Type | Main Purpose | Triggered By | Where Defined 
--- | --- | --- | ---
**Executable** | Producing one-time assets that can then be edited further. | Expand button | BimlScript Library
**Live** | Producing always up-to-date assets (that can't be manually changed). | Any project change; always running. | Within any Biml file.
**Transformer** | Enforcing development patterns during builds. | Build | BimlScript Library & Plugins