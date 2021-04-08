var socialCardTable;

function createSocialCardTable(elementId) {
  socialCardTable = document.getElementById(elementId);
}

function renderTable(socialCardDataObj, fieldMap) {
  var tableHTML = "";
  var fieldMapKeys = Object.keys(fieldMap);

  tableHTML += '<th>Social Media</th><th>URL</th>';

  for (i = 0; i < fieldMapKeys.length; i++) {
    tableHTML += '<tr>';

    var fieldName = fieldMap[fieldMapKeys[i]];
    var fieldValue = socialCardDataObj.socialCardData[fieldMapKeys[i]];

    if (fieldValue != "") {
      tableHTML += '<td>' + fieldName + '</td>';

      tableHTML += '<td>';
      if (fieldMapKeys[i] != 1){
        tableHTML += '<a href="' + fieldValue + '">' + fieldValue + '</a>';
      } else {
        tableHTML += fieldValue;
      }

      tableHTML += '</td>';
    }

    tableHTML += '</tr>';
  }

  socialCardTable.innerHTML = tableHTML;
}
