//
//  ViewController.m
//  searchView
//
//  Created by 512523045@qq.com on 16/3/28.
//  Copyright © 512523045@qq.com All rights reserved.
//

#import "ViewController.h"

#define ButtonTag       100000
#define inputW          32
#define imgSearchW      15

@interface ViewController ()<UITextFieldDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UIView           *inputView;     //左边输入视图
@property (nonatomic , strong) UITextField      *nameTextField; //搜索框
@property (nonatomic , strong) UIImageView      *imgSearch;     //搜索图片
@property (nonatomic , strong) NSMutableArray   *searchBtnData;
@property (nonatomic , strong) NSMutableArray   *dataSource;
@property (nonatomic , strong) UIView           *backView;
@property (nonatomic , strong) UIView           *tableViewBackView;
@property (nonatomic , weak)   UITableView      *searchTableView;//搜索结果展示
@property (nonatomic , strong) UIView           *bgView;//背景
@property (nonatomic , strong) UIButton         *cancelBt;//取消按钮

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    _searchBtnData = [[NSMutableArray alloc]init];
    _dataSource = [[NSMutableArray alloc]init];
    
    [self inputTextField];
    [self notificationCenterAction];//监听
    [self hiddenSearchAnimation];//不搜索状态
}

#pragma mark - 监听键盘的事件
-(void) notificationCenterAction
{
    //监听键盘的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextFieldTextDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.view.window];
}

#pragma mark - 屏幕的伸缩
//键盘升起时动画
- (void)keyboardWillShow:(NSNotification*)notif
{
    [self searchAnimation];
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification*)notif
{
    
    [self hiddenSearchAnimation];
}

-(void) inputTextField {
    
    //添加手势，单击收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //背景图
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgView];
    
    //输入框
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 6, self.view.frame.size.width - 30, 32)];
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    _nameTextField.placeholder = @"请输入客户名/电话";
    _nameTextField.delegate = self;
    [self desigeTextField:_nameTextField];//自定义搜索框样式
    //设置输入框内容的字体样式和大小
    _nameTextField.font = [UIFont fontWithName:@"Arial" size:16.0f];
    _nameTextField.textColor = [UIColor blackColor];
    [self.bgView addSubview:_nameTextField];
    
    //取消按钮
    self.cancelBt = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBt.frame = CGRectMake(self.view.frame.size.width, 14, 40, 16);
    [self.cancelBt setTitle:@"取消" forState:0];
    [self.cancelBt setTitleColor:[UIColor grayColor] forState:0];
    self.cancelBt.titleLabel.font = [UIFont systemFontOfSize:16];
    self.cancelBt.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.cancelBt addTarget:self action:@selector(cancelBtAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.cancelBt];

    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bgView.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(_nameTextField.frame)-30)];
    self.tableViewBackView = backView;
    [self.view addSubview:backView];
}

//MARK: - --- 自定义搜索框样式
- (void)desigeTextField:(UITextField *)searchField{
    
    [searchField setBackgroundColor:[UIColor whiteColor]];
    searchField.layer.cornerRadius = 16.0f;
    searchField.layer.borderColor = [UIColor colorWithRed:225/255.0 green:227/255.0 blue:229/255.0 alpha:1].CGColor;  //225,227,229
    searchField.layer.borderWidth = 1;
    searchField.layer.masksToBounds = YES;
}

//MARK: - --- 取消按钮点击事件
- (void)cancelBtAction:(UIButton *)button{
    _nameTextField.text = @"";
    [_nameTextField endEditing:YES];
    [self.backView removeFromSuperview];
    [self.dataSource removeAllObjects];
    [self.searchTableView reloadData];
}

//MARK: - --- 显示搜索状态
-(void) searchAnimation
{
    
    _nameTextField.frame = CGRectMake(15, 6, self.view.frame.size.width - 73, 32);
    self.cancelBt.frame = CGRectMake(self.view.frame.size.width - 45, 14, 40, 16);
    
    self.inputView.frame= CGRectMake(0, 0 ,inputW , inputW);
    
    CGRect rx = CGRectMake( 12,(inputW - imgSearchW)/2 , imgSearchW, imgSearchW);
    self.imgSearch.frame = rx;
    
}

//显示隐藏状态
-(void) hiddenSearchAnimation {
    self.nameTextField.frame = CGRectMake(15, 6, self.view.frame.size.width - 30, 32);
    self.cancelBt.frame = CGRectMake(self.view.frame.size.width, 14, 40, 16);
    
    self.inputView = [[UIView alloc] init];
    CGSize size = [_nameTextField.placeholder sizeWithAttributes:@{NSFontAttributeName:_nameTextField.font}];
    CGFloat textFieldW = (_nameTextField.frame.size.width-size.width)/2;
    self.inputView.frame= CGRectMake(0, 0 ,textFieldW , inputW);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputViewTapped)];
    tap.cancelsTouchesInView = NO;
    [self.inputView addGestureRecognizer:tap];
    
    self.imgSearch = [[UIImageView alloc] init];
    self.imgSearch.image = [UIImage imageNamed:@"SearchImg.png"];
    CGRect rx = CGRectMake( textFieldW -12 , (inputW - imgSearchW)/2 , imgSearchW, imgSearchW);
    self.imgSearch.frame = rx;
    
    [self.inputView addSubview:self.imgSearch];
    // 把leftVw设置给文本框
    _nameTextField.leftView = self.inputView;
    _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    
}

- (void)TextFieldTextDidChange {
    
    if (_nameTextField.text.length == 0) {
        self.searchTableView.alpha = 0;
        return;
    }
    if (_nameTextField.text.length > 0) {
        self.searchTableView.alpha = 1;
    }
    [self getSearchResult:_nameTextField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.text.length == 0) {
        UIView *backView = [[UIView alloc]initWithFrame:self.view.bounds];
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.backView = backView;
        [self.tableViewBackView addSubview:backView];
        
        UITableView *searchTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        searchTableView.alpha = 0;
        searchTableView.delegate = self;
        searchTableView.dataSource = self;
        searchTableView.tableFooterView = [UIView new];
        self.searchTableView = searchTableView;
        [self.tableViewBackView addSubview:searchTableView];
    }
}

- (void)inputViewTapped {
    
    [_nameTextField becomeFirstResponder];
    
}

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    
    if ([_nameTextField.text length] == 0) {
        
        [_nameTextField endEditing:YES];
        [self.backView removeFromSuperview];
        
    }
}

- (void)getSearchResult:(NSString *)text {

    //textFiled 改变，执行数据请求
    [self.dataSource removeAllObjects];
    NSArray *array = @[@"长沙",@"12346",@"1245",@"1246",@"111",@"123",@"100",@"1"];
    for (NSString *arrText in array) {
        if ([arrText hasPrefix:text]) {
            
            [self.dataSource addObject:arrText];
        }
    }
    [self.searchTableView reloadData];
}


#pragma tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"SearchViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
