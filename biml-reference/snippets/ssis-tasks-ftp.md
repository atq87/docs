# FTP

```biml
<Biml xmlns="http://schemas.varigence.com/biml.xsd">
    <Packages>
        <Package Name="My Package" ConstraintMode="Linear">
            <Tasks>
                <!-- FTP a remote file from an FTP server to the local machine -->
                <Ftp Name="Ftp Task" Operation="Receive" ConnectionName="MyFtpConnection" >
                    <ExternalFileInput ExternalFilePath="c:\public" FileUsageType="ExistingFolder" />
                    <RemotePath>/logs/staging.varigence.com.log</RemotePath>
                </Ftp>
            </Tasks>
        </Package>
    </Packages>
</Biml>
```
