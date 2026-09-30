pub fn contact_form() -> String {
  "<form class='contact-form'>
    <div class='form-field'>
      <label for='name'>Your name</label>
      <input id='name' name='name' type='text' autocomplete='name' placeholder='Beatrice Wren'>
    </div>
    <div class='form-field'>
      <label for='email'>Work email</label>
      <input id='email' name='email' type='email' autocomplete='email' placeholder='beatrice@example.com'>
    </div>
    <div class='form-field'>
      <label for='flock-size'>Flock size</label>
      <select id='flock-size' name='flock-size'>
        <option value=''>Select a range</option>
        <option>1–10 pigeons</option>
        <option>11–100 pigeons</option>
        <option>101–1,000 pigeons</option>
        <option>More pigeons than we can legally count</option>
      </select>
    </div>
    <div class='form-field'>
      <label for='message'>What can we help with?</label>
      <textarea id='message' name='message' rows='5' placeholder='We need to improve cross-town delivery times…'></textarea>
    </div>
    <button class='primary-button' type='submit' disabled>Send to the loft</button>
    <p class='form-note'>The form looks the part, but it is not connected to a submission service yet.</p>
  </form>"
}
