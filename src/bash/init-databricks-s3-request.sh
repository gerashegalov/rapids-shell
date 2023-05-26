# patch log4j config to instrument S3 API requests
#
LOG4J2_XML_PATCHED="/tmp/log4j2-with-s3-requests.xml"
LOG4J2_CONF_DIR="/databricks/spark/dbconf/log4j"
if [[ "$DB_IS_DRIVER" == "TRUE" ]]; then
  LOG4J2_XML="${LOG4J2_CONF_DIR}/driver/log4j2.xml"
else
  LOG4J2_XML="${LOG4J2_CONF_DIR}/executor/log4j2.xml"
fi

cat << EOF > debug_s3_log.py
import os
import xml.etree.ElementTree as ET

logXml = ET.parse("$LOG4J2_XML")
root = logXml.getroot()
loggers = root.find('Loggers')
ET.SubElement(loggers, 'Logger', {
  'name': 'com.amazonaws.request',
  'level': 'DEBUG'
})
with open("$LOG4J2_XML_PATCHED", 'wb') as f:
  f.write(ET.tostring(root))
EOF

python debug_s3_log.py

# copy and verify patch
diff $LOG4J2_XML_PATCHED $LOG4J2_XML || true
rm $LOG4J2_XML
cp $LOG4J2_XML_PATCHED $LOG4J2_XML
diff $LOG4J2_XML_PATCHED $LOG4J2_XML
